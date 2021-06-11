#!/bin/sh
#$ -j y
#$ -l m_mem_free=3G
#$ -o logs/

matlab -nodisplay -r "$1"
