#!/bin/sh

mono /app/masic/MASIC_Console.exe \
/I:/data/test_global/raw/*.raw \
/O:/data/test_global/masic_output/ \
/P:/parameters/TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml \
> /data/test_global/step00_masic.log