#!/bin/bash

rm -rf ./debug/minimal-csv.gml
ogr2ogr -f GMLAS ./debug/minimal-csv.gml \
    ./data/minimal-csv/ \
    -dsco 'INPUT_XSD=https://cnigfr.github.io/PCRS/schemas/CNIG_PCRS_v2.0.xsd'

echo "----------------------------------------------------"
echo "-- ./debug/minimal-csv.gml :"
echo "----------------------------------------------------"
cat ./debug/minimal-csv.gml

