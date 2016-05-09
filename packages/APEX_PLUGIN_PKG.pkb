create or replace package body apex_plugin_pkg
as

function MAPBOX_MAP_RENDER (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_region_render_result IS
     v_map_name  VARCHAR2(2000);
     v_exe_code  CLOB;
     v_width     varchar2(200);
     v_height    varchar2(200);
     v_init_view VARCHAR2(3000);
    BEGIN
        v_map_name  := p_region.attribute_01;
        v_width     := p_region.attribute_02;
        v_height    := p_region.attribute_03;
        v_init_view := p_region.attribute_04;
        
        v_exe_code := 'apex.plugins.mapbox.map = new apex.plugins.mapBoxMap' ||
            '({ mapRegionId:"R' || p_region.id || ' .t-Region-body", '       || 
            '   mapName    :"'  || v_map_name  || '",'                       || 
            '   width      :"'  || v_width     || '",'                       ||
            '   height     :"'  || v_height    || '",'                       ||
            '   initalView : '  || v_init_view     || ' });';
    
        apex_javascript.add_onload_code(
           p_code => v_exe_code
        );
    
    return NULL;
END MAPBOX_MAP_RENDER;

function MAPBOX_INCLUDE (
    p_item                in apex_plugin.t_page_item,
    p_plugin              in apex_plugin.t_plugin,
    p_value               in varchar2,
    p_is_readonly         in boolean,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_page_item_render_result    
    IS 
    v_api_key VARCHAR2(2000);
    BEGIN
    
    v_api_key := p_item.attribute_01;
    
    apex_plugin_util.debug_page_item (
            p_plugin                  => p_plugin,
            p_page_item           => p_item,
            p_value                   => p_value,
            p_is_readonly          => p_is_readonly,
            p_is_printer_friendly => p_is_printer_friendly );
            
     sys.htp.p('<script src="https://api.mapbox.com/mapbox.js/v2.2.4/mapbox.js"></script>');
     sys.htp.p('<link href="https://api.mapbox.com/mapbox.js/v2.2.4/mapbox.css" rel="stylesheet" />');
    
    sys.htp.p('<script>');
    sys.htp.p('L.mapbox.accessToken = "' || v_api_key || '"');
    sys.htp.p('</script>');
    
    return NULL;
    END MAPBOX_INCLUDE;    
end apex_plugin_pkg;
/