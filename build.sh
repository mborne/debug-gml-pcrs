#!/bin/bash

mkdir -p debug
rm -rf debug/*

for NAME in GeoVendee_PCRS_Montaigu_fixed GeoVendee_PCRS_Montaigu_minimal GeoVendee_PCRS_Montaigu_posList;
do
    echo "GMLAS - ./data/${NAME}.gml => ./debug/${NAME}.vtabs-gmlas ..."
    rm -rf ./debug/${NAME}.vtabs-gmlas
    ogr2ogr --config 'GML_FIELDTYPES' 'ALWAYS_STRING' -f 'CSV' -lco 'GEOMETRY=AS_WKT' \
        -lco 'STRING_QUOTING=IF_NEEDED' -lco 'LINEFORMAT=CRLF' \
        -oo 'REMOVE_UNUSED_LAYERS=YES' -oo 'XSD=https://cnigfr.github.io/PCRS/schemas/CNIG_PCRS_v2.0.xsd' \
        "./debug/${NAME}.vtabs-gmlas" \
        "GMLAS:./data/${NAME}.gml"

    echo "GML - ./data/${NAME}.gml => ./debug/${NAME}.vtabs-gml ..."
    ogr2ogr --config 'GML_FIELDTYPES' 'ALWAYS_STRING' -f 'CSV' -lco 'GEOMETRY=AS_WKT' \
        -lco 'STRING_QUOTING=IF_NEEDED' -lco 'LINEFORMAT=CRLF' \
        "./debug/${NAME}.vtabs-gml" \
        "./data/${NAME}.gml"
done


