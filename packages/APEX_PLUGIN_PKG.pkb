create or replace package body apex_plugin_pkg
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
    
    
function mapbox_map_render (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
    return apex_plugin.t_region_render_result IS
     v_map_name  VARCHAR2(2000);
     v_exe_code  CLOB;
     v_width     varchar2(200);
     v_height    varchar2(200);
     v_init_view VARCHAR2(3000);
     v_region_id varchar2(200);
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
        
        v_exe_code := 'window.apex.plugins.mapbox.map = new apex.plugins.mapBoxMap' ||
            '({ mapRegionContainer:"' || v_region_id || ' .t-Region-body", ' ||
            '   mapRegionId:"'  || v_region_id || '",'                       || 
            '   mapName    :"'  || v_map_name  || '",'                       || 
            '   width      :"'  || v_width     || '",'                       ||
            '   height     :"'  || v_height    || '",'                       ||
            '   initalView : '  || v_init_view     || ' });';
    
        apex_javascript.add_onload_code(
           p_code => v_exe_code
        );
    
    return NULL;
END mapbox_map_render;

function mapbox_include (
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
    
    if f_is_playground = false then
        apex_javascript.add_library(p_name           => 'mapbox.init',
                                    p_directory      => p_plugin.file_prefix,
                                    p_version        => NULL,
                                    p_skip_extension => FALSE);
    end if;
            
    sys.htp.p('<script src="https://api.mapbox.com/mapbox.js/v2.2.4/mapbox.js"></script>');
    sys.htp.p('<link href="https://api.mapbox.com/mapbox.js/v2.2.4/mapbox.css" rel="stylesheet" />');
    
    sys.htp.p('<script>');
    sys.htp.p('L.mapbox.accessToken = "' || v_api_key || '"');
    sys.htp.p('</script>');
    
    return NULL;
end mapbox_include; 

end apex_plugin_pkg;
/
