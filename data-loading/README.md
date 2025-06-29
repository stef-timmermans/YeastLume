This directory loads the paired image data required for the BBDM model. Specifically, it creates sets of data in the project root (in [`/data`](../data)), in the following format:
```
data/train/A    # training reference (bright-field)
data/train/B    # training ground truth (fluorescence)
data/val/A      # validating reference (bright-field)
data/val/B      # validating ground truth (fluorescence)
data/test/A     # testing reference (bright-field)
data/test/B     # testing ground truth (fluorescence)
```

A configuration file is then utilized to point the model to the correct path for training, validation, and testing data. Please see [the homepage of the BBDM repository](https://github.com/xuekt98/BBDM) for more information.

The [single frame testing notebook](test_single_frame.ipynb) can be used to debug and try new logic, which should be brought forward into the [full preprocessing notebook](data_preprocessing.ipynb). Please see the files [`raw-data/README.md`](raw-data/README.md) and [`example-data/README.md`](example-data/README.md) if more context is required in terms of input data.

