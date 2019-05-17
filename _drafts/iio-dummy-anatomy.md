---
layout: post
title:  "The iio_simple_dummy Anatomy"
date:   2019-03-16
published: true
categories: iio
author: siqueira
---

For several days I dove into the Industrial I/O (IIO) subsystem as an attempt
to finish the set of tasks proposed by Daniel Baluta [3]. I decided to put a
lot of effort into Daniel’s assignments, due to my plans to write device
drivers for the IIO subsystem in the near future (I hope). As a result, I
decided to share/register all the knowledge acquired after long hours studying
the `iio_dummy` module (I believe this will help newcomers like me). Finally,
you will find here some general information about the IIO subsystem and details
about the `iio_dummy` module internals.

## Introduction

Usually, I approach a new Device Driver (DD) that I want to learn
systematically. First, I like to focus on identifying the initialization
functions. Second, I concentrate efforts on discovering the essential elements
of the subsystem. Third, I try to seek the read/write functions and dissect
them to comprehend their overall behavior. Finally, I manage to put all the
concepts together. I do not know if it is a great approach, but I use it in
this post.

The best place to start with the IIO subsystem is the `iio_dummy module`, which
is a toy DD. This module has thousands of valuable comments that aid developers
to understand the IIO internal. We look at the `iio_dummy`, starting on
`iio_simple_dummy`; then we go through `iio_simple_dummy_event`, and
`iio_simple_dummy_buffer` in another post.

## The IIO Dummy Channels Setup

Let’s start the `iio_dummy` dissection by looking at the struct `iio_chan_spec`
since it provides several valuable information that helps to understand the
implementation of the other modules. Also, this struct says a lot about the
target devices. We have to start off by defining and explaining the channel
concept:

**Definition:** Channel
: An IIO device channel is a representation of a data channel; A single IIO
device may have one or more channels [[1]](https://01.org/linuxgraphics/gfx-docs/drm/driver-api/iio/index.html).
{: .definition}

To better understand this concept, the IIO documentation provides the following
excellent examples [[1]](https://01.org/linuxgraphics/gfx-docs/drm/driver-api/iio/index.html):

> * An accelerometer can have up to 3 channels representing acceleration on X, Y,
>   and Z axes;
> * A light sensor with two channels indicating the measurements in the visible
>   and infrared spectrum;
> * A thermometer sensor has one channel representing the temperature
>   measurement.

A channel representation in the IIO subsystem requires a struct named
`iio_chan_spec`, declared at `include/linux/iio/iio.h`, which has fields to set
up channels. The `iio_chan_spec` is massively configurable; this feature adds
flexibility to the subsystem because the same struct is used to configure a
different set of devices. It is worth looking at the code documentation located
on top of this struct definition.

The `iio_dummy` create multiple channels to simulate a variety of sensors. As a
result, this part of the code is a little bit large although simple. See the
snippet of code extracted from  `drivers/iio/dummy/iio_simple_dummy.c`:

```c
static const struct iio_chan_spec iio_dummy_channels[] = {
  /* indexed ADC channel in_voltage0_raw etc */
  {
    .type = IIO_VOLTAGE,
    /* Channel has a numeric index of 0 */
    .indexed = 1,
    .channel = 0,
```
{% include add_caption.html
   caption="Code 1: First part of iio_dummy channel configurations" %}

Code 1 is the beginning of the `iio_dummy_channels` declaration. It is an array
of `iio_chan_spec`, where each element describes a different channel. The field
of the first element it is `.type`.  This field specifies the type of
measurements collected by the channel; in this case, it is an `IIO_VOLTAGE`. 

In the above piece of code (Code 1), pay attention to the `.indexed` and
`.channel` field. The `.indexed` value is a bit field element. The value '1' in
this field means that the channel has a numerical index; otherwise, there is no
index value. The `.channel` is the index number assigned to the channel. In
summary, this is a way to distinguish multiple data channels in the same
channel (remember the example of the light sensor).

```c
    /* What other information is available? */
    .info_mask_separate =
    /*
     * in_voltage0_raw
     * Raw (unscaled no bias removal etc) measurement
     * from the device.
     */
    BIT(IIO_CHAN_INFO_RAW) |
    /*
     * in_voltage0_offset
     * Offset for userspace to apply prior to scale
     * when converting to standard units (microvolts)
     */
    BIT(IIO_CHAN_INFO_OFFSET) |
    /*
     * in_voltage0_scale
     * Multipler for userspace to apply post offset
     * when converting to standard units (microvolts)
     */
    BIT(IIO_CHAN_INFO_SCALE),
```
{% include add_caption.html
   caption="Code 2: .info_mask_separate field"  %}

The field `.info_mask_separate` designates which attributes are specific for
this channel. Read the comment on the options to understand the meaning of each
one (the comments are very descriptive).

**Go back and look again at the above fields, we will see it again in the next
section. They play a very important role in the device.**
{: .success}


```c
    /*
     * sampling_frequency
     * The frequency in Hz at which the channels are sampled
     */
    .info_mask_shared_by_dir = BIT(IIO_CHAN_INFO_SAMP_FREQ),
```
{% include add_caption.html
   caption="Code 3: .info_mask_shared_by_dir field"  %}


The field `info_mask_shared_by_dir` is the information mask shared by direction
(e.g., in or out); which means that the channel information is shared with
other channels that have the same direction.

```c
    /* The ordering of elements in the buffer via an enum */
    .scan_index = DUMMY_INDEX_VOLTAGE_0,
    .scan_type = { /* Description of storage in buffer */
      .sign = 'u', /* unsigned */
      .realbits = 13, /* 13 bits */
      .storagebits = 16, /* 16 bits used for storage */
      .shift = 0, /* zero shift */
},

```
{% include add_caption.html
   caption="Code 4: .scan_index and .scan_type field" %}

The `.scan_index` and `.scan_type` are directly related to buffers. If
`.scan_index` receives -1, it means the channels do not support buffered
capture; hence the `.scan_type` is not necessary in this case. However, if
`.scan_index` gets a positive number it means the channel implements a buffer;
it is important to highlight that `.scan_index` must be unique. The
`.scan_index` value is used to organize the order in which the enabled channels
are arranged inside the buffer. Going back to Code 4, `.scan_index` is 0
because of the `DUMMY_INDEX_VOLTAGE_0` which is declared in
`dummy/iio_simple_dummy.h`. Finally, the `.scan_type` represents the buffer
data description.

```c
#ifdef CONFIG_IIO_SIMPLE_DUMMY_EVENTS
    .event_spec = &iio_dummy_event,
    .num_event_specs = 1,
#endif /* CONFIG_IIO_SIMPLE_DUMMY_EVENTS */
  },
```
{% include add_caption.html
   caption="Code 5: .event_spec" %}

There are two final configurations at the end of the first channel, both
related to events. Notice that events became available only if
`CONFIG_IIO_SIMPLE_DUMMY_EVENTS` is enabled in the `.config` file. In a few
words, the `.event_spec` field register an array of events, and the
`.num_event_specs` is the size of the array. We discuss events in a future
tutorial.

Let's keep looking at the other channels; however, we only focus on new things.

```c
/* Differential ADC channel in_voltage1-voltage2_raw etc*/
	{
		.type = IIO_VOLTAGE,
		.differential = 1,
```
{% include add_caption.html
   caption="Code 6: Differential" %}

Code 6 shows an ADC converter, which is configured as a differential.

```c
		/*
		 * Indexing for differential channels uses channel
		 * for the positive part, channel2 for the negative.
		 */
		.indexed = 1,
		.channel = 1,
		.channel2 = 2,
```
{% include add_caption.html
  caption="Code 7: Multiple Channels" %}

The field `.channel2` and `.differential` are directly related to the above
Code; The `.channel2` keeps the differential value number. Here we have the
first example of a single channel, with multiple information.

```c
		/*
		 * in_voltage1-voltage2_raw
		 * Raw (unscaled no bias removal etc) measurement
		 * from the device.
		 */
		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
		/*
		 * in_voltage-voltage_scale
		 * Shared version of scale - shared by differential
		 * input channels of type IIO_VOLTAGE.
		 */
		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_SCALE),
```
{% include add_caption.html
  caption="Code 8: .info_mask_separate and .info_maks_shared_by_type" %}

Finally, the field `.info_mask_shared_by_type` represents a shared channel
attribute of the same type which means that other channels can access this
information. The rest of this channel definition is similar to the last one,
let's skip the rest of the code and look at the next channel.

```c
/*
	 * 'modified' (i.e. axis specified) acceleration channel
	 * in_accel_z_raw
	 */
	{
		.type = IIO_ACCEL,
```
{% include add_caption.html
  caption="Code 9: .type" %}

Here we have a different type of device represented by the `IIO_ACCEL` which
means acceleration channel.

```c
		.modified = 1,
		/* Channel 2 is use for modifiers */
		.channel2 = IIO_MOD_X,
```
{% include add_caption.html
  caption="Code 10: .modified" %}

Here we have another technique to distinguish between data channels in the same
channel. If the `.modified` field is assigned, the `.channel2` changes its
meaning and expects a unique characteristic for the channel. In the Code 10,
this channel receives `IIO_MOD_X`. The rest of the channel definition is
similar to the last one, so let's go to another different thing.

uouuu... a lot of information. I recommend you stop reading for a while, and go
back to the code and read `iio_dummy_channels` in the `iio_dummy` module. Then
come back here.

## The `iio_dummy_read_raw()` Function

Now it is time to look into some real code. Do you remember the `.type` field
from the last section? So, here this field will play an important role.

```c
static int iio_dummy_read_raw(struct iio_dev *indio_dev,
			      struct iio_chan_spec const *chan,
			      int *val,
			      int *val2,
			      long mask)
{
	struct iio_dummy_state *st = iio_priv(indio_dev);
	int ret = -EINVAL;

	mutex_lock(&st->lock);
```
{% include add_caption.html
  caption="Code 12: iio_dummy_read_raw" %}

The `iio_dummy_read_raw` function read data from the `iio_dummy_state` and save it
on `*val` and `*val2` parameters. The ‘mask’ argument, provides the required
information for finding the correct identification of a channel attribute.
Finally, look at the `mutex_lock`, the read operation is under the lock to keep
reading consistent.

```c
	switch (mask) {
	case IIO_CHAN_INFO_RAW: /* magic value - channel value read */
		switch (chan->type) {
		case IIO_VOLTAGE:
			if (chan->output) {
				/* Set integer part to cached value */
				*val = st->dac_val;
				ret = IIO_VAL_INT;
			} else if (chan->differential) {
				if (chan->channel == 1)
					*val = st->differential_adc_val[0];
				else
					*val = st->differential_adc_val[1];
				ret = IIO_VAL_INT;
			} else {
				*val = st->single_ended_adc_val;
				ret = IIO_VAL_INT;
			}
			break;
		case IIO_ACCEL:
			*val = st->accel_val;
			ret = IIO_VAL_INT;
			break;
		default:
			break;
		}
		break;
```
{% include add_caption.html
  caption="Code 13: Find the correct output" %}

Notice that 'mask' refers to the field `.info_mask_separate`, which is used to
identify the correct channel to read. Second, inside the switch statement, the
`type` field (from `iio_chan_spec`) is inspected and based on its value an
action occurs. In this section of the code, the `*val` pointer receives the
value provided by the `iio_dummy_state` struct (which has the sensor state). We
will stop the explanation of the read function here because the rest of it is
similar to the above code.

## The `*write_raw` Function

The `iio_dummy_write_raw()` function is similar to `iio_dummy_read_raw()`; It has
the mask parameter which is used to identify the target channel and write/use
the information in the `iio_dummy_state` struct. Different from the read
function, the write operation receives the values in the arguments and writes
them in the iio_dummy_state struct. Let’s start looking at the essential things
about `iio_dummy_write_raw()`:

```c
static int iio_dummy_write_raw(struct iio_dev *indio_dev,
			       struct iio_chan_spec const *chan,
			       int val,
			       int val2,
			       long mask)
{
	int i;
	int ret = 0;
	struct iio_dummy_state *st = iio_priv(indio_dev);

	switch (mask) {
	case IIO_CHAN_INFO_RAW:
		switch (chan->type) {
		case IIO_VOLTAGE:
			if (chan->output == 0)
				return -EINVAL;

			/* Locking not required as writing single value */
			mutex_lock(&st->lock);
			st->dac_val = val;
			mutex_unlock(&st->lock);
			return 0;
		default:
			return -EINVAL;
		}
```
{% include add_caption.html
  caption="Code 14: write data" %}

As can be seen in Code 14, the implementation resembles the read function.
However, notice that locking is only used when we want to write data in the
state struct, i.e., `iio_dummy_state` is a critical section.

## Putting Things Together with Probe Function

Until now, we just looked at distinct parts of each element of the `iio_dummy`
module. Now it is time to understand how things are connected. Typically, IIO
drivers register itself as an I2C or SPI driver [1], and requires two
functions: `probe` and `remove`. The former is responsible for allocating
memory, initialize device fields, and register the device. The latter, is not
mandatory, basically undo what probe function did. Let’s start looking at the
`iio_dummy_probe`:

```c
static struct iio_sw_device *iio_dummy_probe(const char *name)
```
{% include add_caption.html
  caption="Code 15: Signature" %}

This signature is specifically used for software devices, frequently, an
interface that works with I2C or SPI have a different signature.

```c
	int ret;
	struct iio_dev *indio_dev;
	struct iio_dummy_state *st;
	struct iio_sw_device *swd;

	swd = kzalloc(sizeof(*swd), GFP_KERNEL);
	if (!swd) {
		ret = -ENOMEM;
		goto error_kzalloc;
	}
	/*
	 * Allocate an IIO device.
	 *
	 * This structure contains all generic state
	 * information about the device instance.
	 * It also has a region (accessed by iio_priv()
	 * for chip specific state information.
	 */
	indio_dev = iio_device_alloc(sizeof(*st));
	if (!indio_dev) {
		ret = -ENOMEM;
		goto error_ret;
	}
```
{% include add_caption.html
  caption="Code 16: Allocate" %}

The `probe` function has three main tasks. The first task allocates memory
for an IIO device. In Code 16 we can see the space allocated to store the
`iio_dummy_state`.

```c

	st = iio_priv(indio_dev);
	mutex_init(&st->lock);

	iio_dummy_init_device(indio_dev);
	/*
	 * With hardware: Set the parent device.
	 * indio_dev->dev.parent = &spi->dev;
	 * indio_dev->dev.parent = &client->dev;
	 */

	 /*
	 * Make the iio_dev struct available to remove function.
	 * Bus equivalents
	 * i2c_set_clientdata(client, indio_dev);
	 * spi_set_drvdata(spi, indio_dev);
	 */
	swd->device = indio_dev;

	/*
	 * Set the device name.
	 *
	 * This is typically a part number and obtained from the module
	 * id table.
	 * e.g. for i2c and spi:
	 *    indio_dev->name = id->name;
	 *    indio_dev->name = spi_get_device_id(spi)->name;
	 */
	indio_dev->name = kstrdup(name, GFP_KERNEL);

	/* Provide description of available channels */
	indio_dev->channels = iio_dummy_channels;
	indio_dev->num_channels = ARRAY_SIZE(iio_dummy_channels);

	/*
	 * Provide device type specific interface functions and
	 * constant data.
	 */
	indio_dev->info = &iio_dummy_info;

	/* Specify that device provides sysfs type interfaces */
	indio_dev->modes = INDIO_DIRECT_MODE;
```
{% include add_caption.html
  caption="Code 17: Data initialization" %}

The second task of `probe` is taking care of data initialization. Take a
careful look at Code 17, and you will notice how it handles basic
initializations.

```c
	ret = iio_simple_dummy_events_register(indio_dev);
	if (ret < 0)
		goto error_free_device;

	ret = iio_simple_dummy_configure_buffer(indio_dev);
	if (ret < 0)
		goto error_unregister_events;

	ret = iio_device_register(indio_dev);
	if (ret < 0)
		goto error_unconfigure_buffer;

	iio_swd_group_init_type_name(swd, name, &iio_dummy_type);

	return swd;
```
{% include add_caption.html
  caption="Code 18: Register" %}

The final task of the probe function, is the device register.

## Conclusion

In this brief anatomy, we studied the main data structures and functions
related to the IIO subsystem. I strongly recommend you to take some time to
read again the data struct related to the channels and also the read and write
functions. For the next tutorial, we want to make hand zone study.

## Acknowledgments

I would like to thanks Matheus Tavares for his review and contributions for
this tutorial.

## History

1. V1: Release
2. V2: Reviewed-by: Matheus Tavares

## References

1. [IIO Documentation](https://01.org/linuxgraphics/gfx-docs/drm/driver-api/iio/index.html)
2. [A nice slide about IIO which helped me to understand the subsystem](https://www.slideshare.net/anilchowdary2050/127-iio-anewsubsystem?from_action=save)
3. [IIO tasks proposed by Daniel Baluta](https://kernelnewbies.org/IIO_tasks)
