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
,p_supported_ui_types=>'DESKTOP'
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
,p_prompt=>'map name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '0A66756E6374696F6E206D6170426F784D61702870526567696F6E49642C206D61704E616D6529207B0A202020207661722024203D20617065782E6A51756572792C20726567696F6E203D202428222322202B2070526567696F6E4964293B0A0A202020';
wwv_flow_api.g_varchar2_table(2) := '20696628726567696F6E2E6C656E67746820213D3D203129207B0A2020202020207468726F7720226D6170426F784D61703A20496E76616C696420726567696F6E2073656C6563746F72223B0A202020207D0A202020200A20202020726567696F6E2E61';
wwv_flow_api.g_varchar2_table(3) := '6464436C61737328226D6170626F782D6D617022293B0A202020202F2F204372656174652061206D617020696E207468652064697620236D61700A202020204C2E6D6170626F782E6D617028726567696F6E2E6765742830292C20276D6170626F782E73';
wwv_flow_api.g_varchar2_table(4) := '74726565747327293B0A7D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(1880648085729250)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_file_name=>'mapbox.map.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E6C6561666C65742D626F74746F6D2C202E6C6561666C65742D746F70207B0A20202020706F736974696F6E3A206162736F6C7574653B0A202020207A2D696E6465783A2038303B0A20202020706F696E7465722D6576656E74733A206E6F6E653B0A7D';
wwv_flow_api.g_varchar2_table(2) := '0A0A2E6D6170626F782D6D61702C0A2E6D61702D626F64792D777261702C0A2E6D6170626F782D6D6170202E742D526567696F6E2D626F6479577261707B0A202020206865696768743A313030253B0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(1883212371785402)
,p_plugin_id=>wwv_flow_api.id(1876239888551200)
,p_file_name=>'mapbox.map.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
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
