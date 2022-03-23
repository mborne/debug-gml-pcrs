# debug-gml-pcrs

> French here : [README.md](README.md)

Reproducing a problem regarding the reading of <gml:coordinates> related to the presence of spaces and line breaks with [ogr2ogr](https://gdal.org/programs/ogr2ogr.html) and the [GMLAS](https://gdal.org/drivers/vector/gmlas.html) driver.

## Problem

In the source GML, we have for example:

```xml
<featureMember>
<AffleurantEnveloppePCRS gml:id="GEOMETRIE.ENV.AffleurantEnveloppePCRS.857590">
    <pcrs:geometrie xmlns:pcrs="http://cnig.gouv.fr/pcrs">
    <gml:Polygon srsDimension="3" srsName="EPSG:3947">
        <gml:exterior>
        <gml:LinearRing>
            <gml:coordinates>
                1372074.8935456767,6205942.497461504,40.425811736193694
                1372074.5535202357,6205942.435638697,40.425811736193694
                1372074.5071531301,6205942.690657778,40.425811736193694
                1372074.8471785712,6205942.752480585,40.425811736193694
                1372074.8935456767,6205942.497461504,40.425811736193694
            </gml:coordinates>
        </gml:LinearRing>
        </gml:exterior>
    </gml:Polygon>
    </pcrs:geometrie>
</AffleurantEnveloppePCRS>
</featureMember>
```

By converting to CSV with GDAL/ogr2ogr, and depending on the driver used (GML or GMLAS), we get a different WKT for the geometry :

| GDAL Driver | WKT                                                                                                                                                                                                                                                                         |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **GML**     | "POLYGON Z ((1372074.89354568 6205942.4974615 40.4258117361937,1372074.55352024 6205942.4356387 40.4258117361937,1372074.50715313 6205942.69065778 40.4258117361937,1372074.84717857 6205942.75248059 40.4258117361937,1372074.89354568 6205942.4974615 40.4258117361937))" |
| **GMLAS**   | "POLYGON Z ((0.0 1372074.89354568 1372074.89354568,1372074.89354568 1372074.55352024 0,6205942.4356387 1372074.50715313 0,6205942.69065778 1372074.84717857 0,6205942.75248059 1372074.89354568 0,6205942.4974615 0.0 0))"                                                  |

With GMLAS, we end up with values ​​suggesting a bug during the reading :

* x=0.0
* y=1372074.89354568 (which corresponds to x)
* z=1372074.89354568 (which corresponds to x)

## Analysis

It appears that this problem comes from spaces and line breaks in `<gml:coordinates>` which should only contain:

* Digits (`[0..9]`)
* Dots (`.`) = default value of "decimal" in `<gml:coordinates>`)
* Commas (`,`) = default value of "cs" in `<gml:coordinates>`
* Spaces (` `) = default value of "ts" in `<gml:coordinates>`

## Data to reproduce the issue

| File                                                                              | Description                                                              |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [data/GeoVendee_PCRS_Montaigu_minimal.gml](data/GeoVendee_PCRS_Montaigu_minimal.gml) | Extract from a dataset with problematic spaces and line breaks |
| [data/GeoVendee_PCRS_Montaigu_fixed.gml](data/GeoVendee_PCRS_Montaigu_fixed.gml)     | Removal of the unnecessary line breaks and spaces                       |
| [data/GeoVendee_PCRS_Montaigu_fixed.gml](data/GeoVendee_PCRS_Montaigu_posList.gml)   | Use of `<gml:posList>` rather than the deprecated `<gml:coordinates>`      |

## Script reproducing the problem

See [build.sh](build.sh)

## Results with the GMLAS driver

* [debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gmlas/affleurantenveloppepcrs.csv](debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gmlas/affleurantenveloppepcrs.csv) : **KO** (`POLYGON Z ((0.0 x1 x1,...`)
* [debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gmlas/affleurantenveloppepcrs.csv](debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gmlas/affleurantenveloppepcrs.csv) : **OK** (corrigé)
* [debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gmlas/affleurantenveloppepcrs.csv](debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gmlas/affleurantenveloppepcrs.csv) **OK** (corrigé)

## Results with the GML driver

* [debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gml/AffleurantEnveloppePCRS.csv](debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gml/AffleurantEnveloppePCRS.csv) : **OK**
* [debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gml/AffleurantEnveloppePCRS.csv](debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gml/AffleurantEnveloppePCRS.csv) : **OK**
* [debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gml/AffleurantEnveloppePCRS.csv](debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gml/AffleurantEnveloppePCRS.csv) : **OK**


## Solution

The solution is to remove unnecessary spaces and line breaks…

```xml
<gml:Polygon srsDimension="3" srsName="EPSG:3947">
    <gml:exterior>
        <gml:LinearRing>
            <gml:coordinates>
            1372074.8935456767,6205942.497461504,40.425811736193694
            1372074.5535202357,6205942.435638697,40.425811736193694
            1372074.5071531301,6205942.690657778,40.425811736193694
            1372074.8471785712,6205942.752480585,40.425811736193694
            1372074.8935456767,6205942.497461504,40.425811736193694
            </gml:coordinates>
        </gml:LinearRing>
    </gml:exterior>
</gml:Polygon>
```

=>

```xml
<gml:Polygon srsDimension="3" srsName="EPSG:3947">
    <gml:exterior>
        <gml:LinearRing>
            <!-- removing spaces and line break -->
            <gml:coordinates>1372074.8935456767,6205942.497461504,40.425811736193694 1372074.5535202357,6205942.435638697,40.425811736193694 1372074.5071531301,6205942.690657778,40.425811736193694 1372074.8471785712,6205942.752480585,40.425811736193694 1372074.8935456767,6205942.497461504,40.425811736193694</gml:coordinates>
        </gml:LinearRing>
    </gml:exterior>
</gml:Polygon>
```

...or eventually to use `<gml:posList>` by specifying the dimension of the coordinates:

```xml
<gml:Polygon srsDimension="3" srsName="EPSG:3947">
    <gml:exterior>
        <gml:LinearRing>
            <!-- because coordinates is deprecated (see http://www.datypic.com/sc/niem21/e-gml32_LinearRing.html ) -->
            <gml:posList srsDimension="3">1372074.8935456767 6205942.497461504 40.425811736193694 1372074.5535202357 6205942.435638697 40.425811736193694 1372074.5071531301 6205942.690657778 40.425811736193694 1372074.8471785712 6205942.752480585 40.425811736193694 1372074.8935456767 6205942.497461504 40.425811736193694</gml:posList>
        </gml:LinearRing>
    </gml:exterior>
</gml:Polygon>
```

## Remarks

* Problem has been reproduced with two versions of GDAL :
  * **GDAL 2.4.2, released 2019/06/28** installed with ubuntugis
  * **GDAL 3.4.1, released 2021/12/27** installed with conda

* `<gml:coordinates>` offers (too) many options ("decimal", "cs", "ts") to make a validation possible using a XSD schema and for a reading tool to be tolerant with spaces and line breaks (cf. [gml32_coordinates](https://www-datypic-com.translate.goog/sc/niem21/e-gml32_coordinates.html) ) => **to be considered, a specific check in [IGNF/validator](https://github.com/IGNF/validator)?**

* `<gml:posList>` brings fewer options than `<gml:coordinates>` (but one less useless option = one less risk of hitting a bug while reading with a tool)
* ogr2ogr/GMLAS could however fail more cleanly while reading => **create an issue in https://github.com/OSGeo/gdal/tree/master/ogr/ogrsf_frmts/gmlas )?**

