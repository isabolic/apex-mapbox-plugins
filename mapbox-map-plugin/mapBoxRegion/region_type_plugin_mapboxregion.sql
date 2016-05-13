set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.2.00.07'
,p_default_workspace_id=>999999
,p_default_application_id=>100
,p_default_owner=>'PLAYGROUND'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/mapboxregion
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(1876239888551200)
,p_plugin_type=>'REGION TYPE'
,p_name=>'MAPBOXREGION'
,p_display_name=>'mapBoxRegion'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'http://playground/ws/mapbox.map.js'
,p_css_file_urls=>'http://playground/ws/mapbox.map.css'
,p_render_function=>'APEX_PLUGIN_PKG.MAPBOX_MAP_RENDER'
,p_standard_attributes=>'SOURCE_PLAIN'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>7
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1876594396576562)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Map name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1888799716368004)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Width'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1889392312371543)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Height'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'300px'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1963371068356827)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'initalView'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(1975720498447416)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_name=>'mapboxmap-change-bbox'
,p_display_name=>'mapBoxMap change bbox'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(1976269458478792)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_name=>'mapboxmap-change-zoomlevel'
,p_display_name=>'mapBoxMap change zoomLevel'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(2007832288071810)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_name=>'mapboxmap-maximize-region'
,p_display_name=>'mapBoxMap maximize region'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
