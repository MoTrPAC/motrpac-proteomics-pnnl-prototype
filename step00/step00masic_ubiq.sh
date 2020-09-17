#!/bin/sh

mono /app/masic/MASIC_Console.exe \
/I:/data/test_ubiq/raw/*.raw \
/O:/data/test_ubiq/masic_output/ \
/P:/parameters/TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml \
| tee /data/test_ubiq/step00_masic.log