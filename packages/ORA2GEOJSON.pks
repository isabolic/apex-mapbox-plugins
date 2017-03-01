--------------------------------------------------------
--  DDL for Package ORA2GEOJSON
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "ORA2GEOJSON" AS

  FUNCTION get_row_properties (p_select VARCHAR2, RID ROWID) RETURN clob deterministic;
  FUNCTION sdo2geojson(p_select VARCHAR2,
                       p_rid ROWID,
                       p_geometry       in sdo_geometry,
                       p_decimal_places in pls_integer default 9,
                       p_compress_tags  in pls_integer default 0,
                       p_relative2mbr   in pls_integer default 0)
  RETURN clob deterministic;
 FUNCTION sdo2geojson_partial(p_select VARCHAR2,
                       p_rid ROWID,
                       p_geometry       in sdo_geometry,
                       p_decimal_places in pls_integer default 9,
                       p_compress_tags  in pls_integer default 0,
                       p_relative2mbr   IN pls_integer DEFAULT 0)
  RETURN clob deterministic;
END ORA2GEOJSON;


--

/
