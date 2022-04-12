DELETE FROM arp_digiplan_v1.dokument; 
DELETE FROM arp_digiplan_v1.gemeinde; 

WITH typ_geobasisdaten_dokument AS 
(
    SELECT 
        t_id, 
        typ_grundnutzung AS typ_geobasisdaten,
        dokument
    FROM
        arp_nutzungplanung_v1.nutzungsplanung_typ_grundnutzung_dokument
        
    UNION ALL
    
    SELECT
        t_id, 
        typ_ueberlagernd_flaeche AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_typ_ueberlagernd_flaeche_dokument

    UNION ALL 
    
    SELECT
        t_id, 
        typ_ueberlagernd_linie AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_typ_ueberlagernd_linie_dokument

    UNION ALL 
    
    SELECT
        t_id, 
        typ_ueberlagernd_punkt AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_typ_ueberlagernd_punkt_dokument
        
    UNION ALL 
    
    SELECT
        t_id, 
        typ_erschliessung_flaechenobjekt AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.erschlssngsplnung_typ_erschliessung_flaechenobjekt_dokument

    UNION ALL 
    
    SELECT
        t_id, 
        typ_erschliessung_linienobjekt AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.erschlssngsplnung_typ_erschliessung_linienobjekt_dokument

    UNION ALL 
    
    SELECT
        t_id, 
        typ_erschliessung_punktobjekt AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.erschlssngsplnung_typ_erschliessung_punktobjekt_dokument
        
    UNION ALL 
    
    SELECT
        t_id, 
        typ_empfindlichkeitsstufen AS typ_geobasisdaten,
        dokument
    FROM 
        arp_nutzungplanung_v1.laermmpfhktsstfen_typ_empfindlichkeitsstufe_dokument       
)
,
geometrie_collect AS 
(
    SELECT 
        typ_grundnutzung AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_grundnutzung
    GROUP BY
        typ_grundnutzung 
        
    UNION ALL

    SELECT 
        typ_ueberlagernd_flaeche  AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_ueberlagernd_flaeche
    GROUP BY
        typ_ueberlagernd_flaeche 

    UNION ALL

    SELECT 
        typ_ueberlagernd_linie  AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_ueberlagernd_linie
    GROUP BY
        typ_ueberlagernd_linie 
        
    UNION ALL

    SELECT 
        typ_ueberlagernd_punkt  AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.nutzungsplanung_ueberlagernd_punkt
    GROUP BY
        typ_ueberlagernd_punkt
        
    UNION ALL

    SELECT 
        typ_erschliessung_flaechenobjekt  AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.erschlssngsplnung_erschliessung_flaechenobjekt
    GROUP BY
        typ_erschliessung_flaechenobjekt
        
    UNION ALL

    SELECT 
        typ_erschliessung_linienobjekt  AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.erschlssngsplnung_erschliessung_linienobjekt
    GROUP BY
        typ_erschliessung_linienobjekt

    UNION ALL

    SELECT 
        typ_erschliessung_punktobjekt  AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.erschlssngsplnung_erschliessung_punktobjekt
    GROUP BY
        typ_erschliessung_punktobjekt
        
    UNION ALL

    SELECT 
        typ_empfindlichkeitsstufen AS typ_geobasisdaten,
        ST_Collect(geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.laermmpfhktsstfen_empfindlichkeitsstufe
    GROUP BY
        typ_empfindlichkeitsstufen
)
,
dokument_geometrie_collect AS 
(
    SELECT 
        dokument.t_id,
        ST_Collect(geometrie_collect.geometrie) AS geometrie
    FROM 
        arp_nutzungplanung_v1.rechtsvorschrften_dokument AS dokument
        LEFT JOIN typ_geobasisdaten_dokument
        ON dokument.t_id = typ_geobasisdaten_dokument.dokument 
        LEFT JOIN geometrie_collect
        ON geometrie_collect.typ_geobasisdaten = typ_geobasisdaten_dokument.typ_geobasisdaten
    GROUP BY
        dokument.t_id
)
,
dokumente_geometrie_bbox AS 
(
    SELECT 
        t_id,
        ST_XMin (ST_Extent(geometrie)) AS xmin,
        ST_YMin (ST_Extent(geometrie)) AS ymin,
        ST_XMax (ST_Extent(geometrie)) AS xmax,
        ST_YMax (ST_Extent(geometrie)) AS ymax
    FROM 
        dokument_geometrie_collect
    GROUP BY
        t_id 
)

INSERT INTO 
    arp_digiplan_v1.dokument 
    (
        titel,
        offiziellertitel,
        offiziellenummer,
        rrbnr,
        typ,
        textimweb,
        abkuerzung,
        bfsnr,
        gemeindename,
        publiziertab,
        publiziertbis,
        rechtsstatus,
        minx,
        miny,
        maxx,
        maxy,
        avgx,
        avgy,
        ascale,
        searchtext
    )
    SELECT 
        --dokument.t_id,
        --dokument.t_ili_tid,
        dokument.titel,
        dokument.offiziellertitel,
        dokument.offiziellenr AS offiziellenummer,
        CASE 
            WHEN titel ILIKE '%Regierung%' THEN dokument.offiziellenr
        END AS rrbnr,
        CASE 
            WHEN titel ILIKE '%Regierung%' THEN 'Regierungsratsbeschluss'
            WHEN titel ILIKE '%Gestaltung%' THEN 'Gestaltungsplan'
            WHEN titel ILIKE '%Erschliessung%' THEN 'Erschliessungsplan'
            WHEN titel ILIKE '%Sonderbau%' THEN 'Sonderbauvorschrift'
            WHEN titel ILIKE '%Teil%' THEN 'Teilzonenplan'
            WHEN titel ILIKE '%reglement%' THEN 'Bau_Zonenreglement'
            ELSE 'undefiniert'
        END AS typ,
        dokument.textimweb,
        dokument.abkuerzung,
        dokument.gemeinde AS bfsnr,
        gemeinde.gemeindename,
        CASE 
            WHEN dokument.publiziertab IS NULL THEN '2100-12-31'
            ELSE dokument.publiziertab 
        END AS publiziertab,
        --dokument.publiziertab,
        dokument.publiziertbis,
        dokument.rechtsstatus,
        dokumente_geometrie_bbox.xmin,
        dokumente_geometrie_bbox.ymin,
        dokumente_geometrie_bbox.xmax,
        dokumente_geometrie_bbox.ymax,
        CAST((dokumente_geometrie_bbox.xmax - dokumente_geometrie_bbox.xmin)/2 + dokumente_geometrie_bbox.xmin AS int4) AS avgx,
        CAST((dokumente_geometrie_bbox.ymax - dokumente_geometrie_bbox.ymin)/2 + dokumente_geometrie_bbox.ymin AS int4) AS avgy,
        CASE 
            WHEN (dokumente_geometrie_bbox.xmax - dokumente_geometrie_bbox.xmin) > (dokumente_geometrie_bbox.ymax - dokumente_geometrie_bbox.ymin) THEN 
                CASE 
                    WHEN (dokumente_geometrie_bbox.xmax - dokumente_geometrie_bbox.xmin)*3 < 2000 THEN 2000
                    ELSE CAST((dokumente_geometrie_bbox.xmax - dokumente_geometrie_bbox.xmin)*3 AS int4)
                END
            ELSE
                CASE 
                    WHEN (dokumente_geometrie_bbox.ymax - dokumente_geometrie_bbox.ymin)*3 < 2000 THEN 2000
                    ELSE CAST((dokumente_geometrie_bbox.ymax - dokumente_geometrie_bbox.ymin)*3 AS int4)
                END
        END AS ascale,
        concat(dokument.gemeinde, ', ', gemeinde.gemeindename, ', ', dokument.publiziertab, ', ', dokument.offiziellenr, ', ', dokument.offiziellertitel) AS searchText
    FROM 
        arp_nutzungplanung_v1.rechtsvorschrften_dokument AS dokument 
        LEFT JOIN dokumente_geometrie_bbox 
        ON dokument.t_id = dokumente_geometrie_bbox.t_id
        LEFT JOIN agi_hoheitsgrenzen_pub.hoheitsgrenzen_gemeindegrenze AS gemeinde 
        ON gemeinde.bfs_gemeindenummer = dokument.gemeinde 
;

INSERT INTO 
    arp_digiplan_v1.gemeinde 
    (
        aname,
        bfsnr,
        kanton,
        kantonskuerzel        
    )
SELECT 
    gemeindename AS name,
    bfs_gemeindenummer AS bfsnr,
    'Solothurn'::TEXT AS kanton,
    'SO'::TEXT AS kantonskuerzel
FROM 
    agi_hoheitsgrenzen_pub.hoheitsgrenzen_gemeindegrenze AS gemeindegrenze INNER JOIN
    (
        SELECT 
            DISTINCT bfsnr
        FROM 
            arp_digiplan_v1.dokument
    ) AS foo
    ON foo.bfsnr = gemeindegrenze.bfs_gemeindenummer
;
