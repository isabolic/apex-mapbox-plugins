--------------------------------------------------------
--  DDL for Package Body APEX_PLUGIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "APEX_PLUGIN_PKG"
as

    gv_playground_host varchar2(100) := 'PLAYGROUND';

    function f_is_playground return boolean
    is
    v_ax_workspace varchar2(200);
    begin
        select apex_util.find_workspace((select apex_application.get_security_group_id from dual))
          into v_ax_workspace
          from dual;

        if  gv_playground_host = v_ax_workspace then
            return true;
        else
            return false;
        end if;
    end f_is_playground;

    procedure res_out(p_clob  clob) is
        v_char varchar2(32000);
        v_clob clob := p_clob;
    begin
        while length(v_clob) > 0 loop
        begin
            if length(v_clob) > 32000 then
                v_char := substr(v_clob,1,32000);
                sys.htp.prn(v_char);
                v_clob:= substr(v_clob, length(v_char) +1);
            else
                v_char := v_clob;
                sys.htp.prn(v_char);
                v_char := '';
                v_clob := '';
            end if;
        end;
        end loop;
    end res_out;

    function esc(p_txt varchar2) return varchar2 is
    begin
      return sys.htf.escape_sc(p_txt);
    end esc;

    function mapbox_zoom_to_adapter_render (
        p_dynamic_action      in apex_plugin.t_dynamic_action,
        p_plugin              in apex_plugin.t_plugin)
        return apex_plugin.t_dynamic_action_render_result is
            v_exe_code     clob;
            v_region_id    varchar2(200);
            v_bbox_aitem   varchar2(200);
            v_zlevel_aitem varchar2(200);
            v_ax_plg       apex_plugin.t_dynamic_action_render_result;
        begin
            v_region_id    := p_dynamic_action.attribute_01;
            v_zlevel_aitem := p_dynamic_action.attribute_02;

            if f_is_playground = false then
               apex_javascript.add_library(p_name           => 'mapbox.zoomto.adapter',
                                           p_directory      => p_plugin.file_prefix,
                                           p_version        => NULL,
                                           p_skip_extension => FALSE);
            end if;

            v_exe_code := 'window.apex.plugins.mapbox.zoomToAdapter = new apex.plugins.mapbox.MapBoxZoomToAdapter' ||
                '({ mapRegionId   :"'  || v_region_id     || '",'                       ||
                '   zoomLevelItem :"'  || v_zlevel_aitem  || '",'                       ||
                ' });';

            apex_javascript.add_onload_code(
               p_code => v_exe_code
            );

            v_ax_plg.javascript_function := 'window.apex.plugins.mapbox.zoomToAdapter.zoomTo()';

            return v_ax_plg;
    end mapbox_zoom_to_adapter_render;

    function mapbox_loadgeom_adapter_render (
        p_dynamic_action      in apex_plugin.t_dynamic_action,
        p_plugin              in apex_plugin.t_plugin)
        return apex_plugin.t_dynamic_action_render_result is
            v_exe_code     clob;
            v_region_id    varchar2(200);
            v_apex_item    varchar2(200);
            v_geom_style   varchar2(3000);
            v_zoom_to_g    varchar2(10) := 'false';
            v_ax_plg       apex_plugin.t_dynamic_action_render_result;
        begin
            v_region_id    := p_dynamic_action.attribute_01;
            v_apex_item    := p_dynamic_action.attribute_02;
            v_geom_style   := p_dynamic_action.attribute_03;

            if p_dynamic_action.attribute_04 = 'Y' then
                v_zoom_to_g := 'true';
            end if;

            if f_is_playground = false then
               apex_javascript.add_library(p_name           => 'mapbox.load.geometry.adapter',
                                           p_directory      => p_plugin.file_prefix,
                                           p_version        => NULL,
                                           p_skip_extension => FALSE);
            end if;

            v_exe_code := 'window.apex.plugins.mapbox.loadGeometryAdapter = new apex.plugins.mapbox.MapBoxLoadGeometryAdapter' ||
                '({ mapRegionId   :"'  || v_region_id     || '",'                      ||
                '   apexItem      :"'  || v_apex_item     || '",'                      ||
                '   zoomTo        : '  || v_zoom_to_g     || ' ,'                      ||
                '   style         : '  || v_geom_style    || ' ,'                      ||
                '   ajaxIdentifier:"'  || apex_plugin.get_ajax_identifier              ||
                '" });';

            apex_javascript.add_onload_code(
               p_code => v_exe_code
            );

            v_ax_plg.javascript_function := 'function(){window.apex.plugins.mapbox.loadGeometryAdapter.loadFromAjax()}';

            return v_ax_plg;
    end mapbox_loadgeom_adapter_render;

    function mapbox_loadgeom_adapter_ajax (
        p_dynamic_action      in apex_plugin.t_dynamic_action,
        p_plugin              in apex_plugin.t_plugin)
        return apex_plugin.t_dynamic_action_ajax_result
        is
            v_result apex_plugin.t_dynamic_action_ajax_result;
            v_geojson clob;
            v_data_type varchar2(200);
            ex_invalid_type EXCEPTION;
            v_cursor        SYS_REFCURSOR;
            --
            v_id           varchar2(32000) := wwv_flow.g_x01;
            v_owner        varchar2(40)    := p_dynamic_action.attribute_05;
            v_table        varchar2(40)    := p_dynamic_action.attribute_06;
            v_column       varchar2(40)    := p_dynamic_action.attribute_07;
            v_col_name_pk  varchar2(40)    := p_dynamic_action.attribute_08;
            v_col_is_gjson varchar2(1)     := p_dynamic_action.attribute_09;
            v_query_sdo   varchar2(32000) :=
                    'select ora2geojson.sdo2geojson(''select * from #USER#.#TABLE#''
                                       ,rowid
                                       ,#COLUMN#) geom
                       from #USER#.#TABLE# t';

            v_query_json varchar2(32000) :=
                    'select #COLUMN#
                       from #USER#.#TABLE# t';
           v_where      varchar2(200) := ' where t.#COLUMN_ID# = :pk_id';
    begin

        if v_col_name_pk is not null then
            v_query_json := v_query_json || v_where;
            v_query_sdo  := v_query_sdo || v_where;
        end if;

        select atc.data_type
          into v_data_type
          from all_tab_columns atc left join all_synonyms s
               on (atc.owner = s.table_owner and atc.table_name = s.table_name)
         where 1=1
           and atc.table_name = v_table
           and atc.column_name = v_column
           and (atc.owner = v_owner or s.owner = v_owner)
         order by atc.owner, atc.table_name;

        if v_col_name_pk is not null then
            if v_data_type = 'SDO_GEOMETRY' and v_col_is_gjson = 'N' then

                v_query_sdo := replace(v_query_sdo, '#USER#'     , v_owner );
                v_query_sdo := replace(v_query_sdo, '#TABLE#'    , v_table );
                v_query_sdo := replace(v_query_sdo, '#COLUMN#'   , v_column);
                v_query_sdo := replace(v_query_sdo, '#COLUMN_ID#', v_col_name_pk);


                execute immediate v_query_sdo
                   into v_geojson
                  using v_id;

            elsif v_col_is_gjson = 'Y' and v_data_type != 'SDO_GEOMETRY' then
                v_query_json := replace(v_query_json, '#USER#'     , v_owner );
                v_query_json := replace(v_query_json, '#TABLE#'    , v_table );
                v_query_json := replace(v_query_json, '#COLUMN#'   , v_column);
                v_query_json := replace(v_query_json, '#COLUMN_ID#', v_col_name_pk);


                execute immediate v_query_json
                   into v_geojson
                  using v_id;

            elsif v_col_is_gjson = 'N' then
                raise ex_invalid_type;
            end if;

             res_out(v_geojson);

        else
             if v_data_type = 'SDO_GEOMETRY' and v_col_is_gjson = 'N' then

                v_query_sdo := replace(v_query_sdo, '#USER#'     , v_owner );
                v_query_sdo := replace(v_query_sdo, '#TABLE#'    , v_table );
                v_query_sdo := replace(v_query_sdo, '#COLUMN#'   , v_column);


                OPEN v_cursor for v_query_sdo;

            elsif v_col_is_gjson = 'Y' and v_data_type != 'SDO_GEOMETRY' then
                v_query_json := replace(v_query_json, '#USER#'     , v_owner );
                v_query_json := replace(v_query_json, '#TABLE#'    , v_table );
                v_query_json := replace(v_query_json, '#COLUMN#'   , v_column);


                OPEN v_cursor for v_query_json;

            elsif v_col_is_gjson = 'N' then
                raise ex_invalid_type;
            end if;


             LOOP
               FETCH v_cursor INTO v_geojson;
               EXIT WHEN v_cursor%NOTFOUND;
               res_out(v_geojson);
             END LOOP;
        end if;
        return v_result;

    end mapbox_loadgeom_adapter_ajax;

    function mapbox_map_render (
        p_region              in apex_plugin.t_region,
        p_plugin              in apex_plugin.t_plugin,
        p_is_printer_friendly in boolean )
        return apex_plugin.t_region_render_result IS
         v_map_name  varchar2(2000);
         v_exe_code  clob;
         v_width     varchar2(200);
         v_height    varchar2(200);
         v_init_view varchar2(3000);
         v_region_id varchar2(200);
         v_ax_plg    apex_plugin.t_region_render_result;
        BEGIN
            v_map_name  := p_region.attribute_01;
            v_width     := p_region.attribute_02;
            v_height    := p_region.attribute_03;
            v_init_view := p_region.attribute_04;

            v_region_id := p_region.static_id;

            if v_region_id is null then
               v_region_id := 'R' ||  p_region.id;
            end if;

            if f_is_playground = false then
               apex_javascript.add_library(p_name           => 'mapbox.map',
                                           p_directory      => p_plugin.file_prefix,
                                           p_version        => NULL,
                                           p_skip_extension => FALSE);

                   apex_css.add_file (
                        p_name      => 'mapbox.map',
                        p_directory => p_plugin.file_prefix );
            end if;

            v_exe_code := 'window.apex.plugins.mapbox.map = new apex.plugins.mapbox.mapBoxMap' ||
                '({ mapRegionContainer:"' || v_region_id || ' .t-Region-body", ' ||
                '   mapRegionId:"'  || v_region_id || '",'                       ||
                '   mapName    :"'  || v_map_name  || '",'                       ||
                '   width      :"'  || v_width     || '",'                       ||
                '   height     :"'  || v_height    || '",'                       ||
                '   initalView : '  || v_init_view     || ' });';

            apex_javascript.add_onload_code(
               p_code => v_exe_code
            );

        return v_ax_plg;
    END mapbox_map_render;

    function mapbox_include (
        p_item                in apex_plugin.t_page_item,
        p_plugin              in apex_plugin.t_plugin,
        p_value               in varchar2,
        p_is_readonly         in boolean,
        p_is_printer_friendly in boolean )
        return apex_plugin.t_page_item_render_result
        IS
        --
        v_api_key varchar2(2000);
        v_ax_plg  apex_plugin.t_page_item_render_result;
        --
        BEGIN

        v_api_key := p_item.attribute_01;

        if f_is_playground = false then
            apex_javascript.add_library(p_name           => 'mapbox.init',
                                        p_directory      => p_plugin.file_prefix,
                                        p_version        => NULL,
                                        p_skip_extension => FALSE);
        end if;

        res_out('<script src="https://api.mapbox.com/mapbox.js/v2.2.4/mapbox.js"></script>');
        res_out('<link href="https://api.mapbox.com/mapbox.js/v2.2.4/mapbox.css" rel="stylesheet" />');

        res_out('<script>');
        res_out('L.mapbox.accessToken = "' || v_api_key || '"');
        res_out('</script>');

        return v_ax_plg;
    end mapbox_include;


end apex_plugin_pkg;

/
