--------------------------------------------------------
--  DDL for Package Body ORA2GEOJSON
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PLAYGROUND"."ORA2GEOJSON" AS
  FUNCTION get_row_properties (p_select VARCHAR2, RID ROWID) RETURN clob AS
  TYPE curtype IS REF CURSOR;
  src_cur      curtype;
  curid        NUMBER;
  namevar      VARCHAR2(50);
  numvar       NUMBER;
  datevar      DATE;
  desctab      DBMS_SQL.DESC_TAB;
  colcnt       NUMBER;
  v_temp_string   varchar2(30000);
  v_result     CLOB;
  dsql varchar2(1000) := p_select || ' where rowid = CHARTOROWID(''' || ROWIDTOCHAR(RID) || ''')'; --'select * from sdo_segments_all where rownum = 1';
  BEGIN
    OPEN src_cur FOR dsql;
     DBMS_LOB.createtemporary (lob_loc => v_result, cache => TRUE);

 --
  -- Switch from native dynamic SQL to DBMS_SQL package.
  curid := DBMS_SQL.TO_CURSOR_NUMBER(src_cur);
  DBMS_SQL.DESCRIBE_COLUMNS(curid, colcnt, desctab);
 --
  -- Define columns.
  FOR i IN 1 .. colcnt LOOP

    IF desctab(i).col_type <> 109 THEN
       --dbms_output.put_line (desctab(i).col_name || ': ' || desctab(i).col_type);
      IF desctab(i).col_type = 2 THEN
        DBMS_SQL.DEFINE_COLUMN(curid, i, numvar);
      ELSIF desctab(i).col_type = 12 THEN
        DBMS_SQL.DEFINE_COLUMN(curid, i, datevar);
      ELSE
        DBMS_SQL.DEFINE_COLUMN(curid, i, namevar, 50);
      END IF;
    END IF;
  END LOOP;
  --
  -- Fetch rows with DBMS_SQL package.
  WHILE DBMS_SQL.FETCH_ROWS(curid) > 0 LOOP
    v_temp_string := ' ';
    FOR i IN 1 .. colcnt LOOP
      IF desctab(i).col_type <> 109 THEN
      --dbms_output.put_line (desctab(i).col_name);
      v_temp_string :=v_temp_string || '"' || desctab(i).col_name || '": ';
       --dbms_output.put_line('v_temp_string Start: ' || nvl(v_temp_string, 'IS NULL'));
      IF (desctab(i).col_type = 1) THEN
        DBMS_SQL.COLUMN_VALUE(curid, i, namevar);
        IF namevar IS null THEN
          --dbms_output.put_line('its null');
          v_temp_string:=v_temp_string || 'null, ';
        ELSE
         v_temp_string:=v_temp_string || '"' || namevar || '", ';
        END IF;

        --dbms_output.put_line('v_temp_string String: ' || nvl(v_temp_string, 'IS NULL'));
      ELSIF (desctab(i).col_type = 2) THEN
        DBMS_SQL.COLUMN_VALUE(curid, i, numvar);
         IF numvar IS null THEN
          --dbms_output.put_line('its null');
          v_temp_string:=v_temp_string || 'null, ';
        ELSE
          v_temp_string:=v_temp_string || to_char(replace(numvar,',','.')) || ', ';
        END IF;

        --dbms_output.put_line('v_temp_string number: ' || nvl(v_temp_string, 'IS NULL'));
      ELSIF (desctab(i).col_type = 12) THEN
        DBMS_SQL.COLUMN_VALUE(curid, i, datevar);
        --dbms_output.put_line('its a date');
        IF datevar IS null THEN
          --dbms_output.put_line('its null');
          v_temp_string:=v_temp_string || 'null, ';
        ELSE
          v_temp_string:=v_temp_string || '"' || to_char(datevar,'DD/MM/YYYY') || '", ';
        END IF;
        --dbms_output.put_line('v_temp_string Date: ' || nvl(v_temp_string, 'IS NULL'));
      END IF;
      --dbms_output.put_line('v_temp_string: ' || nvl(v_temp_string, 'IS NULL'));
      DBMS_LOB.write(lob_loc => v_result,
                     amount => LENGTH (v_temp_string),
                     offset => 1,
                     buffer => v_temp_string );
      END IF;
    END LOOP;
  END LOOP;
  --
  DBMS_SQL.CLOSE_CURSOR(curid);
  DBMS_LOB.write(lob_loc => v_result,
                     amount => LENGTH (v_temp_string),
                     offset => 1,
                     buffer => v_temp_string );
  DBMS_LOB.TRIM (v_result, DBMS_LOB.GETLENGTH(v_result)-2);
  RETURN v_result;
  END get_row_properties;
  --
  -----
  --
  FUNCTION hASRectangles( p_elem_info in mdsys.sdo_elem_info_array  )
    RETURN Pls_Integer
  IS
     v_rectangle_count number := 0;
     v_etype           pls_integer;
     v_interpretation  pls_integer;
     v_elements        pls_integer;
  BEGIN
     IF ( p_elem_info IS null ) THEN
        RETURN 0;
     END IF;
     v_elements := ( ( p_elem_info.COUNT / 3 ) - 1 );
     <<element_extraction>>
     for v_i IN 0 .. v_elements LOOP
       v_etype := p_elem_info(v_i * 3 + 2);
       v_interpretation := p_elem_info(v_i * 3 + 3);
       IF  ( v_etype in (1003,2003) AND v_interpretation = 3  ) THEN
           v_rectangle_count := v_rectangle_count + 1;
       END IF;
     END loop element_extraction;
     RETURN v_rectangle_Count;
  END hASRectangles;

  FUNCTION hASCircularArcs(p_elem_info in mdsys.sdo_elem_info_array)
     RETURN boolean
   IS
     v_elements  number;
   BEGIN
     v_elements := ( ( p_elem_info.COUNT / 3 ) - 1 );
     <<element_extraction>>
     for v_i IN 0 .. v_elements LOOP
        IF ( ( /* etype */         p_elem_info(v_i * 3 + 2) = 2 AND
               /* interpretation*/ p_elem_info(v_i * 3 + 3) = 2 )
             OR
             ( /* etype */         p_elem_info(v_i * 3 + 2) in (1003,2003) AND
               /* interpretation*/ p_elem_info(v_i * 3 + 3) IN (2,4) ) ) THEN
               RETURN true;
        END IF;
     END loop element_extraction;
     RETURN false;
  END hASCircularArcs;
 --
 ----
 --
  FUNCTION GetNumRings( p_geometry  in mdsys.sdo_geometry,
                        p_ring_type in integer default 0 /* 0 = ALL; 1 = OUTER; 2 = INNER */ )
    RETURN Number
  IS
     v_ring_count number := 0;
     v_ring_type  number := p_ring_type;
     v_elements   number;
     v_etype      pls_integer;
  BEGIN
     IF ( p_geometry IS null ) THEN
        RETURN 0;
     END IF;
     IF ( p_geometry.sdo_elem_info IS null ) THEN
        RETURN 0;
     END IF;
     IF ( v_ring_type not in (0,1,2) ) THEN
        v_ring_type := 0;
     END IF;
     v_elements := ( ( p_geometry.sdo_elem_info.COUNT / 3 ) - 1 );
     <<element_extraction>>
     for v_i IN 0 .. v_elements LOOP
       v_etype := p_geometry.sdo_elem_info(v_i * 3 + 2);
       IF  ( v_etype in (1003,1005,2003,2005) and 0 = v_ring_type )
        OR ( v_etype in (1003,1005)           and 1 = v_ring_type )
        OR ( v_etype in (2003,2005)           and 2 = v_ring_type ) THEN
           v_ring_count := v_ring_count + 1;
       END IF;
     END loop element_extraction;
     RETURN v_ring_count;
  END GetNumRings;
  --
  ----
  --
  PROCEDURE ADD_Coordinate( p_ordinates  in out nocopy mdsys.sdo_ordinate_array,
                            p_dim        in number,
                            p_x_coord    in number,
                            p_y_coord    in number,
                            p_z_coord    in number,
                            p_m_coord    in number,
                            p_meASured   in boolean := false,
                            p_duplicates in boolean := false)
    IS
      FUNCTION Duplicate
        RETURN Boolean
      IS
      BEGIN
        RETURN CASE WHEN p_ordinates IS null or p_ordinates.count = 0
                    THEN False
                    ELSE CASE p_dim
                              WHEN 2
                              THEN ( p_ordinates(p_ordinates.COUNT)   = p_y_coord
                                     AND
                                     p_ordinates(p_ordinates.COUNT-1) = p_x_coord )
                              WHEN 3
                              THEN ( p_ordinates(p_ordinates.COUNT)   =  CASE WHEN p_meASured THEN p_m_coord ELSE p_z_coord END
                                     AND
                                     p_ordinates(p_ordinates.COUNT-1) = p_y_coord
                                     AND
                                     p_ordinates(p_ordinates.COUNT-2) = p_x_coord )
                              WHEN 4
                              THEN ( p_ordinates(p_ordinates.COUNT)   = p_m_coord
                                     AND
                                     p_ordinates(p_ordinates.COUNT-1) = p_z_coord
                                     AND
                                     p_ordinates(p_ordinates.COUNT-2) = p_y_coord
                                     AND
                                     p_ordinates(p_ordinates.COUNT-3) = p_x_coord )
                          END
                  END;
      END Duplicate;

  BEGIN
    IF ( p_ordinates IS null ) THEN
       p_ordinates := new mdsys.sdo_ordinate_array(null);
       p_ordinates.DELETE;
    END IF;
    IF ( p_duplicates or Not Duplicate() ) THEN
      IF ( p_dim >= 2 ) THEN
        p_ordinates.extEND(2);
        p_ordinates(p_ordinates.count-1) := p_x_coord;
        p_ordinates(p_ordinates.count  ) := p_y_coord;
      END IF;
      IF ( p_dim >= 3 ) THEN
        p_ordinates.extEND(1);
        p_ordinates(p_ordinates.count)   := CASE WHEN p_dim = 3 And p_meASured
                                                 THEN p_m_coord
                                                 ELSE p_z_coord
                                            END;
      END IF;
      IF ( p_dim = 4 ) THEN
        p_ordinates.extEND(1);
        p_ordinates(p_ordinates.count)   := p_m_coord;
      END IF;
    END IF;
  END ADD_Coordinate;
 --
 ----
 --
  FUNCTION Rectangle2Polygon(p_geometry in mdsys.sdo_geometry)
    RETURN mdsys.sdo_geometry
  AS
    v_dims      pls_integer;
    v_ordinates mdsys.sdo_ordinate_array := new mdsys.sdo_ordinate_array(null);
    v_vertices  mdsys.vertex_set_type;
    v_etype     pls_integer;
    v_start_coord mdsys.vertex_type;
    v_END_coord   mdsys.vertex_type;
  BEGIN
      v_ordinates.DELETE;
      v_dims        := p_geometry.get_dims();
      v_etype       := p_geometry.sdo_elem_info(2);
      v_vertices    := sdo_util.getVertices(p_geometry);
      v_start_coord := v_vertices(1);
      v_END_coord   := v_vertices(2);
      -- First coordinate
      ADD_Coordinate( v_ordinates, v_dims, v_start_coord.x, v_start_coord.y, v_start_coord.z, v_start_coord.w );
      -- Second coordinate
      IF ( v_etype = 1003 ) THEN
        ADD_Coordinate(v_ordinates,v_dims,v_END_coord.x,v_start_coord.y,(v_start_coord.z + v_END_coord.z) /2, v_start_coord.w);
      ELSE
        ADD_Coordinate(v_ordinates,v_dims,v_start_coord.x,v_END_coord.y,(v_start_coord.z + v_END_coord.z) /2,
            (v_END_coord.w - v_start_coord.w) * ((v_END_coord.x - v_start_coord.x) /
           ((v_END_coord.x - v_start_coord.x) + (v_END_coord.y - v_start_coord.y)) ));
      END IF;
      -- 3rd or middle coordinate
      ADD_Coordinate(v_ordinates,v_dims,v_END_coord.x,v_END_coord.y,v_END_coord.z,v_END_coord.w);
      -- 4th coordinate
      IF ( v_etype = 1003 ) THEN
        ADD_Coordinate(v_ordinates,v_dims,v_start_coord.x,v_END_coord.y,(v_start_coord.z + v_END_coord.z) /2,v_start_coord.w);
      ELSE
        Add_Coordinate(v_ordinates,v_dims,v_END_coord.x,v_start_coord.y,(v_start_coord.z + v_END_coord.z) /2,
            (v_END_coord.w - v_start_coord.w) * ((v_END_coord.x - v_start_coord.x) /
           ((v_END_coord.x - v_start_coord.x) + (v_END_coord.y - v_start_coord.y)) ));
      END IF;
      -- LASt coordinate
      ADD_Coordinate(v_ordinates,v_dims,v_start_coord.x,v_start_coord.y,v_start_coord.z,v_start_coord.w);
      RETURN mdsys.sdo_geometry(p_geometry.sdo_gtype,p_geometry.sdo_srid,null,mdsys.sdo_elem_info_array(1,v_etype,1),v_ordinates);
  END Rectangle2Polygon;
  --
  ----
  --
  FUNCTION formatCoord(p_x        in number,
                       p_y        in number,
                       p_relative in boolean,
                       p_decimal_places integer default 9)
    RETURN varchar2
  AS
  v_mbr           mdsys.sdo_geometry;
  v_precISion     pls_integer  := nvl(p_decimal_places,9);
  v_ret           varchar2(500);
  BEGIN
      EXECUTE IMMEDIATE 'alter session set NLS_NUMERIC_CHARACTERS=''' || '.,' || '''';
      v_ret:= '[' ||
             CASE WHEN p_relative
                  THEN round(p_x - v_mbr.sdo_ordinates(1),v_precISion) || ',' || round(p_y - v_mbr.sdo_ordinates(2),v_precISion)
                  ELSE round(p_x,v_precISion) || ',' || round(p_y,v_precISion)
              END ||
              ']';
       dbms_output.put_line ('v_ret ' || replace(v_ret, ',',','));
      RETURN replace(v_ret, ',',',');
  END formatCoord;
  --
  ----
  --
  FUNCTION sdo2geojson(p_select         varchar2,
                       p_rid            in ROWID,
                       p_geometry       in sdo_geometry,
                       p_decimal_places in pls_integer default 9,
                       p_compress_tags  in pls_integer default 0,
                       p_relative2mbr   in pls_integer default 0)
  RETURN clob deterministic
  /* Note: Does not support curved geometries.
   *        IF required, stroke geometry before calling function.
   * IF Compressed apply bbox to coordinates.....
   * { "type": "Feature",
   *   "bbox": [-180.0, -90.0, 180.0, 90.0],
   *   "geometry": {
   *   "type": "Polygon",
   *   "coordinates": [[ [-180.0, 10.0], [20.0, 90.0], [180.0, -5.0], [-30.0, -90.0] ]]
   *  }
   *  ...
   * }
  */
  AS
  v_relative      boolean := CASE WHEN p_relative2mbr<>0  THEN true ELSE false END;
  v_result        clob;
  v_props         clob;
  v_type          varchar2(50);
  v_compress_tags boolean       := CASE WHEN p_compress_tags<>0 THEN true ELSE false END;
  v_feature_key   varchar2(100) := CASE WHEN v_compress_tags THEN 'F'  ELSE '"Feature"'      END;
  v_bbox_tag      varchar2(100) := CASE WHEN v_compress_tags THEN 'b:' ELSE '"bbox":'        END;
  v_coord_tag     varchar2(100) := CASE WHEN v_compress_tags THEN 'c:' ELSE '"coordinates":' END;
  v_geometry_tag  varchar2(100) := CASE WHEN v_compress_tags THEN 'g:' ELSE '"Geometry":'    END;
  v_type_tag      varchar2(100) := CASE WHEN v_compress_tags THEN 't:' ELSE '"type":'        END;
  v_temp_string   varchar2(30000);
  v_precISion     pls_integer  := nvl(p_decimal_places,9);
  v_i             pls_integer;
  v_num_rings     pls_integer;
  v_num_elements  pls_integer;
  v_element_no    pls_integer;
  v_vertices      mdsys.vertex_set_type;
  v_mbr            mdsys.sdo_geometry;
  v_element       mdsys.sdo_geometry;
  v_ring          mdsys.sdo_geometry;
  v_geometry      mdsys.sdo_geometry := p_geometry;
  BEGIN
  IF ( p_geometry IS null ) THEN
      RETURN null;
  END IF;

  -- Currently, we do not support compound objects
  --
  IF ( p_geometry.get_gtype() not in (1,2,3,5,6,7) ) THEN
    RETURN NULL;
  END IF;

  DBMS_LOB.createtemporary (lob_loc => v_result, cache => TRUE);

  v_type := CASE WHEN v_compress_tags
                 THEN CASE p_geometry.get_gtype()
                           WHEN 1 THEN 'P'
                           WHEN 2 THEN 'LS'
                           WHEN 3 THEN 'PG'
                           WHEN 5 THEN 'MP'
                           WHEN 6 THEN 'MLS'
                           WHEN 7 THEN 'MPG'
                       END
                 ELSE CASE p_geometry.get_gtype()
                           WHEN 1 THEN '"Point"'
                           WHEN 2 THEN '"LineString"'
                           WHEN 3 THEN '"Polygon"'
                           WHEN 5 THEN '"MultiPoint"'
                           WHEN 6 THEN '"MultiLineString"'
                           WHEN 7 THEN '"MultiPolygon"'
                       END
             END;

  v_temp_string := '{';

  IF ( p_geometry.get_gtype() = 1 ) THEN
      v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag;
      IF (p_geometry.SDO_POINT IS not null ) THEN
          v_temp_string := v_temp_string || '[' ||
                           REPLACE(to_char(round(p_geometry.SDO_POINT.X,v_precISion)), ',','.') || ',' ||
                           replace(to_char(round(p_geometry.SDO_POINT.Y,v_precISion)), ',','.') || ']';
      ELSE
          v_temp_string := v_temp_string || '[' ||
                           REPLACE(to_char(round(p_geometry.sdo_ordinates(1),v_precISion)), ',','.') || ',' ||
                           replace(to_char(round(p_geometry.sdo_ordinates(2),v_precISion)), ',','.') || ']';
      END IF;
      dbms_output.put_line ('v_temp_string ' || v_temp_string);
      DBMS_LOB.write(lob_loc => v_result,
                     amount => LENGTH (v_temp_string),
                     offset => 1,
                     buffer => v_temp_string );
      -- Get properties string
      v_props:= get_row_properties(p_select, p_rid);
      v_result := v_result || ', "properties": {' || v_props || '}}';
      --
      RETURN v_result;
  END IF;

  IF ( v_relative ) THEN
     v_mbr := SDO_GEOM.SDO_MBR(p_geometry);
     IF ( v_mbr IS not null ) THEN
         v_temp_string := v_temp_string ||
                          v_type_tag || v_feature_key || ',' ||
                          v_bbox_tag || '[' ||
                          v_mbr.sdo_ordinates(1) || ',' ||
                          v_mbr.sdo_ordinates(2) || ',' ||
                          v_mbr.sdo_ordinates(3) || ',' ||
                          v_mbr.sdo_ordinates(4) || ',' ||
                          '],' || v_geometry_tag || '{';
     END IF;
  END IF;
  -- Cater for Multilinestrings and MultiPolygons
  IF ( p_geometry.get_gtype() = 6 OR p_geometry.get_gtype() = 7) THEN
    v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag ||' [';
  ELSE
    v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag;
  END IF;
  --
  -- Write header
  DBMS_LOB.write(lob_loc => v_result,
                 amount => LENGTH (v_temp_string),
                 offset => 1,
                 BUFFER => v_temp_string);
  --
  IF ( hASCircularArcs(p_geometry.sdo_elem_info) ) THEN
      RETURN null;
  END IF;
  --
  v_num_elements := mdsys.sdo_util.GetNumElem(p_geometry);
  <<for_all_elements>>
  FOR v_element_no IN 1..v_num_elements LOOP
     v_element := mdsys.sdo_util.EXTRACT(p_geometry,v_element_no);   -- Extract element with all sub-elements
      dbms_output.put_line ('v_element.get_gtype() ' || v_element.get_gtype());
     IF ( v_element.get_gtype() in (1,2,5) ) THEN
        IF (v_element_no = 1) THEN
           v_temp_string := '[';
        ELSIF ( v_element.get_gtype() = 2 ) THEN
           v_temp_string := '],[';
        END IF;
        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => DBMS_LOB.GETLENGTH(v_result)+1,
                       buffer => v_temp_string );
        v_vertices := mdsys.sdo_util.getVertices(v_element);
        v_temp_string := formatCoord(v_vertices(1).x,v_vertices(1).y,v_relative);
        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => DBMS_LOB.GETLENGTH(v_result)+1,
                       buffer => v_temp_string );
        <<for_all_vertices>>
        for j in 2..v_vertices.count loop
            v_temp_string := ',' || formatCoord(v_vertices(j).x,v_vertices(j).y,v_relative);
            DBMS_LOB.write(lob_loc => v_result,
                           amount => LENGTH (v_temp_string),
                           offset => DBMS_LOB.GETLENGTH(v_result)+1,
                           buffer => v_temp_string );
        END loop for_all_vertices;
        dbms_output.put_line ('v_temp_string1 ' || v_temp_string);
        dbms_output.put_line ('v_result1 ' || v_result);
     ELSE
        IF (v_element_no = 1) THEN
           v_temp_string := '[';
        ELSE
           v_temp_string := '],[';
        END IF;
        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => DBMS_LOB.GETLENGTH(v_result)+1,
                       buffer => v_temp_string );
        v_num_rings := GetNumRings(v_element);
        <<for_all_rings>>
        FOR v_ring_no in 1..v_num_rings Loop
          v_ring := MDSYS.SDO_UTIL.EXTRACT(p_geometry,v_element_no,v_ring_no);  -- Extract ring from element .. must do it thIS way, can't correctly extract from v_element.
          IF (hASRectangles(v_ring.sdo_elem_info)>0) THEN
             v_ring := Rectangle2Polygon(v_ring);
          END IF;
          IF ( v_ring_no > 1 ) THEN
             v_temp_string := ',';
             DBMS_LOB.write(lob_loc => v_result,
                            amount => LENGTH (v_temp_string),
                            offset => DBMS_LOB.GETLENGTH(v_result)+1,
                            buffer => v_temp_string );
          END IF;
          v_vertices := mdsys.sdo_util.getVertices(v_ring);
          v_temp_string := '[' || formatCoord(v_vertices(1).x,v_vertices(1).y,v_relative);
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );

          <<for_all_vertices>>
          for j in 2..v_vertices.count loop
              v_temp_string := ',' || formatCoord(v_vertices(j).x,v_vertices(j).y,v_relative, p_decimal_places);
              DBMS_LOB.write(lob_loc => v_result,
                             amount => LENGTH (v_temp_string),
                             offset => DBMS_LOB.GETLENGTH(v_result)+1,
                             buffer => v_temp_string );
          END loop for_all_vertices;
          v_temp_string := ']';  -- Close Ring
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );
        END Loop for_all_rings;
     END IF;
  END LOOP for_all_elements;

 -- Closing coord tag
  IF ( p_geometry.get_gtype() = 6 OR p_geometry.get_gtype() = 7) THEN
     v_temp_string := ']]';
  ELSE
   v_temp_string := ']';
  END IF;

  IF ( v_relative and p_geometry.get_gtype() <> 1 ) THEN
      v_temp_string := v_temp_string || '}';
  END IF;

  DBMS_LOB.write(lob_loc => v_result,
                 amount => LENGTH (v_temp_string),
                 offset => DBMS_LOB.GETLENGTH(v_result)+1,
                 buffer => v_temp_string );


  -- Get properties string
  v_props:= get_row_properties(p_select, p_rid);
  v_result := v_result || ', "properties": {' || v_props || '}';
  --
  -- Closing tag
   v_temp_string := '}';
   DBMS_LOB.write(lob_loc => v_result,
                 amount => LENGTH (v_temp_string),
                 offset => DBMS_LOB.GETLENGTH(v_result)+1,
                 buffer => v_temp_string );
  RETURN v_result;
  END sdo2geojson;
  --
  -----------------------------------
  --
  FUNCTION sdo2geojson_partial(p_select         varchar2,
                       p_rid            in ROWID,
                       p_geometry       in sdo_geometry,
                       p_decimal_places in pls_integer default 9,
                       p_compress_tags  in pls_integer default 0,
                       p_relative2mbr   in pls_integer default 0)
  RETURN clob deterministic
  /* Note: Does not support curved geometries.
   *        IF required, stroke geometry before calling function.
   * IF Compressed apply bbox to coordinates.....
   * { "type": "Feature",
   *   "bbox": [-180.0, -90.0, 180.0, 90.0],
   *   "geometry": {
   *   "type": "Polygon",
   *   "coordinates": [[ [-180.0, 10.0], [20.0, 90.0], [180.0, -5.0], [-30.0, -90.0] ]]
   *  }
   *  ...
   * }
  */
  AS
  v_relative      boolean := CASE WHEN p_relative2mbr<>0  THEN true ELSE false END;
  v_result        clob;
  v_props         clob;
  v_type          varchar2(50);
  v_compress_tags boolean       := CASE WHEN p_compress_tags<>0 THEN true ELSE false END;
  v_feature_key   varchar2(100) := CASE WHEN v_compress_tags THEN 'F'  ELSE '"Feature"'      END;
  v_bbox_tag      varchar2(100) := CASE WHEN v_compress_tags THEN 'b:' ELSE '"bbox":'        END;
  v_coord_tag     varchar2(100) := CASE WHEN v_compress_tags THEN 'c:' ELSE '"coordinates":' END;
  v_geometry_tag  varchar2(100) := CASE WHEN v_compress_tags THEN 'g:' ELSE '"Geometry":'    END;
  v_type_tag      varchar2(100) := CASE WHEN v_compress_tags THEN 't:' ELSE '"type":'        END;
  v_temp_string   varchar2(30000);
  v_precISion     pls_integer  := nvl(p_decimal_places,9);
  v_i             pls_integer;
  v_num_rings     pls_integer;
  v_num_elements  pls_integer;
  v_element_no    pls_integer;
  v_vertices      mdsys.vertex_set_type;
  v_mbr            mdsys.sdo_geometry;
  v_element       mdsys.sdo_geometry;
  v_ring          mdsys.sdo_geometry;
  v_geometry      mdsys.sdo_geometry := p_geometry;
  BEGIN
  IF ( p_geometry IS null ) THEN
      RETURN null;
  END IF;

  -- Currently, we do not support compound objects
  --
  IF ( p_geometry.get_gtype() not in (1,2,3,5,6,7) ) THEN
    RETURN NULL;
  END IF;

  DBMS_LOB.createtemporary (lob_loc => v_result, cache => TRUE);

  v_type := CASE WHEN v_compress_tags
                 THEN CASE p_geometry.get_gtype()
                           WHEN 1 THEN 'P'
                           WHEN 2 THEN 'LS'
                           WHEN 3 THEN 'PG'
                           WHEN 5 THEN 'MP'
                           WHEN 6 THEN 'MLS'
                           WHEN 7 THEN 'MPG'
                       END
                 ELSE CASE p_geometry.get_gtype()
                           WHEN 1 THEN '"Point"'
                           WHEN 2 THEN '"LineString"'
                           WHEN 3 THEN '"Polygon"'
                           WHEN 5 THEN '"MultiPoint"'
                           WHEN 6 THEN '"MultiLineString"'
                           WHEN 7 THEN '"MultiPolygon"'
                       END
             END;

  v_temp_string := '"type": "Feature", "geometry": {';

  IF ( p_geometry.get_gtype() = 1 ) THEN
      v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag;
      IF (p_geometry.SDO_POINT IS not null ) THEN
          v_temp_string := v_temp_string || '[' ||
                           REPLACE(to_char(round(p_geometry.SDO_POINT.X,v_precISion)), ',','.') || ',' ||
                           replace(to_char(round(p_geometry.SDO_POINT.Y,v_precISion)), ',','.') || ']';
      ELSE
          v_temp_string := v_temp_string || '[' ||
                           REPLACE(to_char(round(p_geometry.sdo_ordinates(1),v_precISion)), ',','.') || ',' ||
                           replace(to_char(round(p_geometry.sdo_ordinates(2),v_precISion)), ',','.') || ']';
      END IF;
      DBMS_LOB.write(lob_loc => v_result,
                     amount => LENGTH (v_temp_string),
                     offset => 1,
                     buffer => v_temp_string );
      -- Get properties string
      v_props:= get_row_properties(p_select, p_rid);
      v_result := v_result || '}, "properties": {' || v_props || '}}';
      --
      RETURN v_result;
  END IF;

  IF ( v_relative ) THEN
     v_mbr := SDO_GEOM.SDO_MBR(p_geometry);
     IF ( v_mbr IS not null ) THEN
         v_temp_string := v_temp_string ||
                          v_type_tag || v_feature_key || ',' ||
                          v_bbox_tag || '[' ||
                          v_mbr.sdo_ordinates(1) || ',' ||
                          v_mbr.sdo_ordinates(2) || ',' ||
                          v_mbr.sdo_ordinates(3) || ',' ||
                          v_mbr.sdo_ordinates(4) || ',' ||
                          '],' || v_geometry_tag || '{';
     END IF;
  END IF;
  -- Cater for Multilinestrings and MultiPolygons
  IF ( p_geometry.get_gtype() = 6 OR p_geometry.get_gtype() = 7) THEN
    v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag ||' [';
  ELSE
    v_temp_string := v_temp_string || v_type_tag || v_type || ',' || v_coord_tag;
  END IF;
  --
  -- Write header
  DBMS_LOB.write(lob_loc => v_result,
                 amount => LENGTH (v_temp_string),
                 offset => 1,
                 BUFFER => v_temp_string);
  --
  IF ( hASCircularArcs(p_geometry.sdo_elem_info) ) THEN
      RETURN null;
  END IF;
  --
  v_num_elements := mdsys.sdo_util.GetNumElem(p_geometry);
  <<for_all_elements>>
  FOR v_element_no IN 1..v_num_elements LOOP
     v_element := mdsys.sdo_util.EXTRACT(p_geometry,v_element_no);   -- Extract element with all sub-elements
      dbms_output.put_line ('v_element.get_gtype() ' || v_element.get_gtype());
     IF ( v_element.get_gtype() in (1,2,5) ) THEN
        IF (v_element_no = 1) THEN
           v_temp_string := '[';
        ELSIF ( v_element.get_gtype() = 2 ) THEN
           v_temp_string := '],[';
        END IF;
        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => DBMS_LOB.GETLENGTH(v_result)+1,
                       buffer => v_temp_string );
        v_vertices := mdsys.sdo_util.getVertices(v_element);
        v_temp_string := formatCoord(v_vertices(1).x,v_vertices(1).y,v_relative);
        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => DBMS_LOB.GETLENGTH(v_result)+1,
                       buffer => v_temp_string );
        <<for_all_vertices>>
        for j in 2..v_vertices.count loop
            v_temp_string := ',' || formatCoord(v_vertices(j).x,v_vertices(j).y,v_relative);
            DBMS_LOB.write(lob_loc => v_result,
                           amount => LENGTH (v_temp_string),
                           offset => DBMS_LOB.GETLENGTH(v_result)+1,
                           buffer => v_temp_string );
        END loop for_all_vertices;
        dbms_output.put_line ('v_temp_string1 ' || v_temp_string);
        dbms_output.put_line ('v_result1 ' || v_result);
     ELSE
        IF (v_element_no = 1) THEN
           v_temp_string := '[';
        ELSE
           v_temp_string := '],[';
        END IF;
        DBMS_LOB.write(lob_loc => v_result,
                       amount => LENGTH (v_temp_string),
                       offset => DBMS_LOB.GETLENGTH(v_result)+1,
                       buffer => v_temp_string );
        v_num_rings := GetNumRings(v_element);
        <<for_all_rings>>
        FOR v_ring_no in 1..v_num_rings Loop
          v_ring := MDSYS.SDO_UTIL.EXTRACT(p_geometry,v_element_no,v_ring_no);  -- Extract ring from element .. must do it thIS way, can't correctly extract from v_element.
          IF (hASRectangles(v_ring.sdo_elem_info)>0) THEN
             v_ring := Rectangle2Polygon(v_ring);
          END IF;
          IF ( v_ring_no > 1 ) THEN
             v_temp_string := ',';
             DBMS_LOB.write(lob_loc => v_result,
                            amount => LENGTH (v_temp_string),
                            offset => DBMS_LOB.GETLENGTH(v_result)+1,
                            buffer => v_temp_string );
          END IF;
          v_vertices := mdsys.sdo_util.getVertices(v_ring);
          v_temp_string := '[' || formatCoord(v_vertices(1).x,v_vertices(1).y,v_relative);
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );

          <<for_all_vertices>>
          for j in 2..v_vertices.count loop
              v_temp_string := ',' || formatCoord(v_vertices(j).x,v_vertices(j).y,v_relative, p_decimal_places);
              DBMS_LOB.write(lob_loc => v_result,
                             amount => LENGTH (v_temp_string),
                             offset => DBMS_LOB.GETLENGTH(v_result)+1,
                             buffer => v_temp_string );
          END loop for_all_vertices;
          v_temp_string := ']';  -- Close Ring
          DBMS_LOB.write(lob_loc => v_result,
                         amount => LENGTH (v_temp_string),
                         offset => DBMS_LOB.GETLENGTH(v_result)+1,
                         buffer => v_temp_string );
        END Loop for_all_rings;
     END IF;
  END LOOP for_all_elements;

 -- Closing coord tag
  IF ( p_geometry.get_gtype() = 6 OR p_geometry.get_gtype() = 7) THEN
     v_temp_string := ']]';
  ELSE
   v_temp_string := ']';
  END IF;

  IF ( v_relative and p_geometry.get_gtype() <> 1 ) THEN
      v_temp_string := v_temp_string || '}';
  END IF;

  DBMS_LOB.write(lob_loc => v_result,
                 amount => LENGTH (v_temp_string),
                 offset => DBMS_LOB.GETLENGTH(v_result)+1,
                 buffer => v_temp_string );


  -- Get properties string
  v_props:= get_row_properties(p_select, p_rid);
  v_result := v_result || ', "properties": {' || v_props || '}';
  --
  -- Closing tag
   v_temp_string := '}';
   DBMS_LOB.write(lob_loc => v_result,
                 amount => LENGTH (v_temp_string),
                 offset => DBMS_LOB.GETLENGTH(v_result)+1,
                 buffer => v_temp_string );
  RETURN v_result;
  END sdo2geojson_partial;
END ORA2GEOJSON;

/
