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
prompt --application/shared_components/plugins/dynamic_action/mapboxloadgeometryadapter
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(8966021210298693)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MAPBOXLOADGEOMETRYADAPTER'
,p_display_name=>'MapBoxLoadGeometryAdapter'
,p_category=>'COMPONENT'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'http://playground/ws/mapbox.load.geometry.adapter.js'
,p_render_function=>'apex_plugin_pkg.mapbox_loadgeom_adapter_render'
,p_ajax_function=>'apex_plugin_pkg.mapbox_loadgeom_adapter_ajax'
,p_standard_attributes=>'ITEM:BUTTON:REGION:JQUERY_SELECTOR:ONLOAD:STOP_EXECUTION_ON_ERROR:WAIT_FOR_RESULT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>2
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8966781050347202)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Map region static ID'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8967680774359718)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Apex item with column id'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_default_value=>'rowid'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8970076550015077)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Geometry style JSON object'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'{}'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(8971517793099712)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Zoom to geometry'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(9001523938246166)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Geometry table owner'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_text_case=>'UPPER'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(9002279978247305)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Geometry table name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_text_case=>'UPPER'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(9004173469252868)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Geometry column name'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(9016814466190877)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Table column id'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(9021969760633533)
,p_plugin_id=>wwv_flow_api.id(8966021210298693)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_prompt=>'Column is already geojson format'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
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
