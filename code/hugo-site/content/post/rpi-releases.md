+++
title = "Rpi Releases"
date = 2018-04-01T10:10:14Z
tags = ["hardware"]
categories = ["linux","rpi-cluster"]

+++

To identify what hardware you have, you can use this command:

```
cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//'
```

hardware revision history:

|          |              |                                 |              |                 |                           |
|----------|--------------|---------------------------------|--------------|-----------------|---------------------------|
| Revision | Release Date | Model                           | PCB Revision | Memory          | Notes                     |
| Beta     | Q1 2012      | B (Beta)                        | ?            | 256 MB          | Beta Board                |
| 2        | Q1 2012      | B                               | 1            | 256 MB          |                           |
| 3        | Q3 2012      | B (ECN0001)                     | 1            | 256 MB          | Fuses mod and D14 removed |
| 4        | Q3 2012      | B                               | 2            | 256 MB          | (Mfg by Sony)             |
| 5        | Q4 2012      | B                               | 2            | 256 MB          | (Mfg by Qisda)            |
| 6        | Q4 2012      | B                               | 2            | 256 MB          | (Mfg by Egoman)           |
| 7        | Q1 2013      | A                               | 2            | 256 MB          | (Mfg by Egoman)           |
| 8        | Q1 2013      | A                               | 2            | 256 MB          | (Mfg by Sony)             |
| 9        | Q1 2013      | A                               | 2            | 256 MB          | (Mfg by Qisda)            |
| 000d     | Q4 2012      | B                               | 2            | 512 MB          | (Mfg by Egoman)           |
| 000e     | Q4 2012      | B                               | 2            | 512 MB          | (Mfg by Sony)             |
| 000f     | Q4 2012      | B                               | 2            | 512 MB          | (Mfg by Qisda)            |
| 10       | Q3 2014      | B+                              | 1            | 512 MB          | (Mfg by Sony)             |
| 11       | Q2 2014      | Compute Module 1                | 1            | 512 MB          | (Mfg by Sony)             |
| 12       | Q4 2014      | A+                              | 1.1          | 256 MB          | (Mfg by Sony)             |
| 13       | Q1 2015      | B+                              | 1.2          | 512 MB          | (Mfg by Embest)           |
| 14       | Q2 2014      | Compute Module 1                | 1            | 512 MB          | (Mfg by Embest)           |
| 15       | ?            | A+                              | 1.1          | 256 MB / 512 MB | (Mfg by Embest)           |
| a01040   | Unknown      | 2 Model B                       | 1            | 1 GB            | (Mfg by Sony)             |
| a01041   | Q1 2015      | 2 Model B                       | 1.1          | 1 GB            | (Mfg by Sony)             |
| a21041   | Q1 2015      | 2 Model B                       | 1.1          | 1 GB            | (Mfg by Embest)           |
| a22042   | Q3 2016      | 2 Model B (with BCM2837)        | 1.2          | 1 GB            | (Mfg by Embest)           |
| 900021   | Q3 2016      | A+                              | 1.1          | 512 MB          | (Mfg by Sony)             |
| 900032   | Q2 2016?     | B+                              | 1.2          | 512 MB          | (Mfg by Sony)             |
| 900092   | Q4 2015      | Zero                            | 1.2          | 512 MB          | (Mfg by Sony)             |
| 900093   | Q2 2016      | Zero                            | 1.3          | 512 MB          | (Mfg by Sony)             |
| 920093   | Q4 2016?     | Zero                            | 1.3          | 512 MB          | (Mfg by Embest)           |
| 9000c1   | Q1 2017      | Zero W                          | 1.1          | 512 MB          | (Mfg by Sony)             |
| a02082   | Q1 2016      | 3 Model B                       | 1.2          | 1 GB            | (Mfg by Sony)             |
| a020a0   | Q1 2017      | Compute Module 3 (and CM3 Lite) | 1            | 1 GB            | (Mfg by Sony)             |
| a22082   | Q1 2016      | 3 Model B                       | 1.2          | 1 GB            | (Mfg by Embest)           |
| a32082   | Q4 2016      | 3 Model B                       | 1.2          | 1 GB            | (Mfg by Sony Japan)       |
| a020d3   | Q1 2018      | 3 Model B+                      | 1.3          | 1 GB            | (Mfg by Sony)             |


source: https://elinux.org/RPi_HardwareHistory
