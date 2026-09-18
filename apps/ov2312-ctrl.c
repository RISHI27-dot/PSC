// SPDX-License-Identifier: GPL-2.0
/*
 * ov2312-ctrl - Set multi-capture exposure and gain controls on OV2312
 *
 * Usage:
 *   ov2312-ctrl [OPTIONS]
 *
 * Options:
 *   -e <rgb>,<ir>   Set V4L2_CID_EXPOSURE_MULTI (lines)
 *   -a <rgb>,<ir>   Set V4L2_CID_AGAIN_MULTI    (analog gain)
 *   -d <rgb>,<ir>   Set V4L2_CID_DGAIN_MULTI    (digital gain)
 *   -D <device>     Subdevice node (default: /dev/v4l-ov2312-subdev0)
 *   -q              Query current control values before setting
 *   -h              Show this help
 *
 * Examples:
 *   ov2312-ctrl -e 1404,144
 *   ov2312-ctrl -e 1404,144 -a 16,16 -d 256,256
 *   ov2312-ctrl -D /dev/v4l-subdev1 -q -e 800,100
 */

#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <linux/v4l2-controls.h>
#include <linux/videodev2.h>

#define DEFAULT_DEV	"/dev/v4l-ov2312-subdev0"

/* Image source class controls added for multi-capture sensors */
#ifndef V4L2_CID_EXPOSURE_MULTI
#define V4L2_CID_EXPOSURE_MULTI		(V4L2_CID_IMAGE_SOURCE_CLASS_BASE + 10)
#define V4L2_CID_AGAIN_MULTI		(V4L2_CID_IMAGE_SOURCE_CLASS_BASE + 11)
#define V4L2_CID_DGAIN_MULTI		(V4L2_CID_IMAGE_SOURCE_CLASS_BASE + 12)
#endif

struct ctrl_arg {
	uint32_t	id;
	const char	*name;
	uint32_t	values[2];	/* [0]=RGB, [1]=IR */
	int		set;		/* 1 if this control should be applied */
};

static void usage(const char *prog)
{
	fprintf(stderr,
		"Usage: %s [OPTIONS]\n"
		"\n"
		"Set multi-capture exposure/gain controls on OV2312.\n"
		"Array index 0 = RGB capture (Group B, VC1, longest exposure)\n"
		"Array index 1 = IR  capture (Group A, VC0, shorter exposure)\n"
		"\n"
		"Options:\n"
		"  -e <rgb>,<ir>   Set EXPOSURE_MULTI (exposure lines)\n"
		"  -a <rgb>,<ir>   Set AGAIN_MULTI    (analog gain)\n"
		"  -d <rgb>,<ir>   Set DGAIN_MULTI    (digital gain)\n"
		"  -D <device>     Subdevice node (default: %s)\n"
		"  -q              Query current values before applying\n"
		"  -h              Show this help\n"
		"\n"
		"Examples:\n"
		"  %s -e 1404,144\n"
		"  %s -e 1404,144 -a 16,16 -d 256,256\n",
		prog, DEFAULT_DEV, prog, prog);
}

static int parse_pair(const char *arg, uint32_t *rgb, uint32_t *ir)
{
	char *end;
	long v0, v1;

	v0 = strtol(arg, &end, 0);
	if (end == arg || *end != ',') {
		fprintf(stderr, "error: expected '<rgb>,<ir>', got '%s'\n", arg);
		return -1;
	}
	v1 = strtol(end + 1, &end, 0);
	if (*end != '\0') {
		fprintf(stderr, "error: trailing characters after '%s'\n", arg);
		return -1;
	}
	if (v0 < 0 || v1 < 0) {
		fprintf(stderr, "error: values must be non-negative\n");
		return -1;
	}

	*rgb = (uint32_t)v0;
	*ir  = (uint32_t)v1;
	return 0;
}

static int query_ctrl(int fd, struct ctrl_arg *c)
{
	uint32_t values[2] = { 0, 0 };
	struct v4l2_ext_control ctrl = {
		.id   = c->id,
		.size = sizeof(values),
		.p_u32 = values,
	};
	struct v4l2_ext_controls ctrls = {
		.which    = V4L2_CTRL_WHICH_CUR_VAL,
		.count    = 1,
		.controls = &ctrl,
	};

	if (ioctl(fd, VIDIOC_G_EXT_CTRLS, &ctrls) < 0) {
		fprintf(stderr, "VIDIOC_G_EXT_CTRLS %s: %s\n",
			c->name, strerror(errno));
		return -1;
	}

	printf("  %-20s [0](RGB)=%-6u [1](IR)=%-6u\n",
	       c->name, values[0], values[1]);
	return 0;
}

static int set_ctrl(int fd, struct ctrl_arg *c)
{
	struct v4l2_ext_control ctrl = {
		.id    = c->id,
		.size  = sizeof(c->values),
		.p_u32 = c->values,
	};
	struct v4l2_ext_controls ctrls = {
		.which    = V4L2_CTRL_WHICH_CUR_VAL,
		.count    = 1,
		.controls = &ctrl,
	};

	if (ioctl(fd, VIDIOC_S_EXT_CTRLS, &ctrls) < 0) {
		fprintf(stderr, "VIDIOC_S_EXT_CTRLS %s: %s\n",
			c->name, strerror(errno));
		return -1;
	}

	printf("  %-20s [0](RGB)=%-6u [1](IR)=%-6u  -> OK\n",
	       c->name, c->values[0], c->values[1]);
	return 0;
}

int main(int argc, char *argv[])
{
	const char *dev = DEFAULT_DEV;
	int query = 0;
	int opt, fd, ret = 0;

	struct ctrl_arg ctrls[] = {
		{ V4L2_CID_EXPOSURE_MULTI, "EXPOSURE_MULTI" },
		{ V4L2_CID_AGAIN_MULTI,    "AGAIN_MULTI"    },
		{ V4L2_CID_DGAIN_MULTI,    "DGAIN_MULTI"    },
	};

	while ((opt = getopt(argc, argv, "e:a:d:D:qh")) != -1) {
		switch (opt) {
		case 'e':
			if (parse_pair(optarg,
				       &ctrls[0].values[0],
				       &ctrls[0].values[1]) < 0)
				return 1;
			ctrls[0].set = 1;
			break;
		case 'a':
			if (parse_pair(optarg,
				       &ctrls[1].values[0],
				       &ctrls[1].values[1]) < 0)
				return 1;
			ctrls[1].set = 1;
			break;
		case 'd':
			if (parse_pair(optarg,
				       &ctrls[2].values[0],
				       &ctrls[2].values[1]) < 0)
				return 1;
			ctrls[2].set = 1;
			break;
		case 'D':
			dev = optarg;
			break;
		case 'q':
			query = 1;
			break;
		case 'h':
			usage(argv[0]);
			return 0;
		default:
			usage(argv[0]);
			return 1;
		}
	}

	if (!ctrls[0].set && !ctrls[1].set && !ctrls[2].set && !query) {
		fprintf(stderr, "error: no controls specified (use -e/-a/-d or -q)\n\n");
		usage(argv[0]);
		return 1;
	}

	fd = open(dev, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "error: cannot open %s: %s\n", dev, strerror(errno));
		return 1;
	}

	if (query) {
		printf("Current values on %s:\n", dev);
		for (int i = 0; i < 3; i++)
			query_ctrl(fd, &ctrls[i]);
		printf("\n");
	}

	for (int i = 0; i < 3; i++) {
		if (!ctrls[i].set)
			continue;
		if (set_ctrl(fd, &ctrls[i]) < 0)
			ret = 1;
	}

	close(fd);
	return ret;
}
