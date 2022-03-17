# debug-gml-pcrs

Reproduction d'un problème de lecture de `<gml:coordinates>` liés à la présence d'espace et saut de lignes avec [ogr2ogr](https://gdal.org/programs/ogr2ogr.html) et le pilote [GMLAS](https://gdal.org/drivers/vector/gmlas.html).

## Problème

Dans le GML source, on a par exemple :

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

En convertissant en CSV avec GDAL/ogr2ogr, on obtient un WKT différent pour la géométrie en fonction du pilote utilisé (GML ou GMLAS) :

| Pilote GDAL | WKT                                                                                                                                                                                                                                                                         |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **GML**     | "POLYGON Z ((1372074.89354568 6205942.4974615 40.4258117361937,1372074.55352024 6205942.4356387 40.4258117361937,1372074.50715313 6205942.69065778 40.4258117361937,1372074.84717857 6205942.75248059 40.4258117361937,1372074.89354568 6205942.4974615 40.4258117361937))" |
| **GMLAS**   | "POLYGON Z ((0.0 1372074.89354568 1372074.89354568,1372074.89354568 1372074.55352024 0,6205942.4356387 1372074.50715313 0,6205942.69065778 1372074.84717857 0,6205942.75248059 1372074.89354568 0,6205942.4974615 0.0 0))"                                                  |

Avec GMLAS, on se retrouve avec des valeurs laissant penser à un bug dans la lecture :

* x=0.0
* y=1372074.89354568 (qui correspond à x)
* z=1372074.89354568 (qui correspond à x)

## Analyse

Il apparaît que ce problème provient des espaces et sauts de lignes dans `<gml:coordinates>` qui ne devrait contenir que :

* Des chiffres (`[0..9]`)
* Des points (`.`) = valeur par défaut de "decimal" dans `<gml:coordinates>`)
* Des virgules (`,`) = valeur par défaut de "cs" dans `<gml:coordinates>`
* Des espaces (` `) = valeur par défaut de "ts" dans `<gml:coordinates>`

## Données de reproduction du problème

| Fichier                                                                              | Description                                                              |
| ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| [data/GeoVendee_PCRS_Montaigu_minimal.gml](data/GeoVendee_PCRS_Montaigu_minimal.gml) | Extrait d'un jeu de données avec espace et saut de ligne posant problème |
| [data/GeoVendee_PCRS_Montaigu_fixed.gml](data/GeoVendee_PCRS_Montaigu_fixed.gml)     | Suppression des sauts de lignes et espace inutiles                       |
| [data/GeoVendee_PCRS_Montaigu_fixed.gml](data/GeoVendee_PCRS_Montaigu_posList.gml)   | Utilisation `<gml:posList>` plutôt que `<gml:coordinates>` qui est dépréciée      |

## Script de reproduction du problème

c.f. [build.sh](build.sh)

## Résultats avec le pilote GMLAS

* [debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gmlas/affleurantenveloppepcrs.csv](debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gmlas/affleurantenveloppepcrs.csv) : **KO** (`POLYGON Z ((0.0 x1 x1,...`)
* [debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gmlas/affleurantenveloppepcrs.csv](debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gmlas/affleurantenveloppepcrs.csv) : **OK** (corrigé)
* [debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gmlas/affleurantenveloppepcrs.csv](debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gmlas/affleurantenveloppepcrs.csv) **OK** (corrigé)

## Résultats avec le pilote GML

* [debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gml/AffleurantEnveloppePCRS.csv](debug/GeoVendee_PCRS_Montaigu_minimal.vtabs-gml/AffleurantEnveloppePCRS.csv) : **OK**
* [debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gml/AffleurantEnveloppePCRS.csv](debug/GeoVendee_PCRS_Montaigu_fixed.vtabs-gml/AffleurantEnveloppePCRS.csv) : **OK**
* [debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gml/AffleurantEnveloppePCRS.csv](debug/GeoVendee_PCRS_Montaigu_postList.vtabs-gml/AffleurantEnveloppePCRS.csv) : **OK**


## Solution

La solution consiste à supprimer les espaces et sauts de ligne inutiles :

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
            <!-- suppression des espaces et saut de ligne -->
            <gml:coordinates>1372074.8935456767,6205942.497461504,40.425811736193694 1372074.5535202357,6205942.435638697,40.425811736193694 1372074.5071531301,6205942.690657778,40.425811736193694 1372074.8471785712,6205942.752480585,40.425811736193694 1372074.8935456767,6205942.497461504,40.425811736193694</gml:coordinates>
        </gml:LinearRing>
    </gml:exterior>
</gml:Polygon>
```

...voire à utiliser `<gml:posList>` en spécifiant la dimension des coordonnées :

```xml
<gml:Polygon srsDimension="3" srsName="EPSG:3947">
    <gml:exterior>
        <gml:LinearRing>
            <!-- car coordinates est dépréciée (c.f. http://www.datypic.com/sc/niem21/e-gml32_LinearRing.html ) -->
            <gml:posList srsDimension="3">1372074.8935456767 6205942.497461504 40.425811736193694 1372074.5535202357 6205942.435638697 40.425811736193694 1372074.5071531301 6205942.690657778 40.425811736193694 1372074.8471785712 6205942.752480585 40.425811736193694 1372074.8935456767 6205942.497461504 40.425811736193694</gml:posList>
        </gml:LinearRing>
    </gml:exterior>
</gml:Polygon>
```
## Remarques

* Problème reproduit avec deux versions de GDAL (**GDAL 2.4.2, released 2019/06/28** installée avec ubuntugis et **GDAL 3.4.1, released 2021/12/27** installée avec conda)
* `<gml:coordinates>` offre de (trop) nombreuses options ("decimal", "cs", "ts") pour qu'une validation par schéma XSD soit possible et qu'un outil de lecture puisse être tolérant sur les espaces et saut de ligne (c.f. [gml32_coordinates](http://www.datypic.com/sc/niem21/e-gml32_coordinates.html)) => **envisager un contrôle spécifique dans IGNF/validator?**?
* `<gml:posList>` offre moins d'options que `<gml:coordinates>` (une option inutile en moins = un risque de bug à la lecture dans un outil en moins)
* ogr2ogr/GMLAS pourrait toutefois échouer plus proprement sur la lecture => **Traduire ce README en anglais et créer un ticket GDAL (https://github.com/OSGeo/gdal/tree/master/ogr/ogrsf_frmts/gmlas) ?**
