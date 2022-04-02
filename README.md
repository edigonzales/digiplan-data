# digiplan-data

```
docker-compose run --user $UID --rm -v $PWD/development_dbs:/home/gradle/project gretl "sleep 20 && cd /home/gradle && gretl -b project/build-dev.gradle importData_NutzungsplanungNachfuehrung importData_Hoheitsgrenzen createSchema_Digiplan"
```

```
java -jar /Users/stefan/apps/ili2pg-4.7.0/ili2pg-4.7.0.jar --dbhost localhost --dbport 54321 --dbdatabase edit --dbusr postgres --dbpwd postgres --models SO_ARP_digiPlan_Publikation_20220402 --modeldir . --strokeArcs --defaultSrsCode 2056 --createMetaInfo --dbschema arp_digiplan_pub --schemaimport
```

```
java -jar /Users/stefan/apps/ili2pg-4.7.0/ili2pg-4.7.0.jar --models SO_ARP_digiPlan_Publikation_20220402 --modeldir . --strokeArcs --defaultSrsCode 2056 --dbschema arp_digiplan_pub --createMetaInfo --createscript fubar.sql 
```

```
java -jar /Users/stefan/apps/ili2h2gis-4.7.0/ili2h2gis-4.7.0.jar --dbfile digiplan_pub --strokeArcs --createEnumTabs --createEnumTxtCol --defaultSrsCode 2056 --models SO_ARP_digiPlan_Publikation_20220402 --modeldir "." --doSchemaImport --import ch.so.arp.digiplan.xtf
```