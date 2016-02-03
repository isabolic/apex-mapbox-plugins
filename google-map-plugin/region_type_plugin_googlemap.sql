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
prompt --application/shared_components/plugins/region_type/googlemap
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(1812238556322772)
,p_plugin_type=>'REGION TYPE'
,p_name=>'GOOGLEMAP'
,p_display_name=>'GoogleMap'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_render_function=>'APEX_PLUGIN_PKG.GOOGLE_MAP_RENDER'
,p_standard_attributes=>'SOURCE_PLAIN'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>12
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E676F6F676C652D6D61707B0D0A202020206865696768743A313030253B0D0A2020202077696474683A313030253B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(1847589276410164)
,p_plugin_id=>wwv_flow_api.id(1812238556322772)
,p_file_name=>'google.map.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '0D0A66756E6374696F6E20676F6F676C654D61702870526567696F6E496429207B0D0A202020207661722024203D20617065782E6A51756572792C20726567696F6E203D202428222322202B2070526567696F6E4964293B0D0A0D0A2020202069662872';
wwv_flow_api.g_varchar2_table(2) := '6567696F6E2E6C656E67746820213D3D203129207B0D0A2020202020207468726F772022676F6F676C654D61703A20496E76616C696420726567696F6E2073656C6563746F72223B0D0A202020207D0D0A0D0A20202020726567696F6E2E617070656E64';
wwv_flow_api.g_varchar2_table(3) := '282428223C6469763E222C7B226964223A226D6170222C22636C617373223A22676F6F676C652D6D6170227D29293B0D0A0D0A20202020676F6F676C654D617050726F6D6973652E646F6E652866756E6374696F6E28297B0D0A2020202020202020676F';
wwv_flow_api.g_varchar2_table(4) := '6F676C654170692E616461707465722E7574696C2E4D6170203D206E657720676F6F676C652E6D6170732E4D617028646F63756D656E742E676574456C656D656E744279496428276D617027292C0D0A202020202020202020207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(5) := '202020202063656E7465723A207B6C61743A2034352E363531343636312C206C6E673A2031352E3637343731357D2C0D0A2020202020202020202020207A6F6F6D3A20380D0A202020202020202020207D0D0A2020202020202020293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(6) := '207D0D0A20202020293B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(1854693750843898)
,p_plugin_id=>wwv_flow_api.id(1812238556322772)
,p_file_name=>'google.map.js'
,p_mime_type=>'application/javascript'
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
