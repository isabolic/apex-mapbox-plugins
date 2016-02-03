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
prompt --application/shared_components/plugins/item_type/googleapikey
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(1822404000443611)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'GOOGLEAPIKEY'
,p_display_name=>'GoogleApiKeyInclude'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_render_function=>'APEX_PLUGIN_PKG.GOOGLE_MAP_API_INCLUDE'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>4
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(1822652291448130)
,p_plugin_id=>wwv_flow_api.id(1822404000443611)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Google api Key'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2866756E6374696F6E2028297B0D0A2020202077696E646F772E676F6F676C65417069203D207B7D3B0D0A2020202077696E646F772E676F6F676C654170692E61646170746572203D207B7D3B0D0A0D0A20202020676F6F676C654170692E6164617074';
wwv_flow_api.g_varchar2_table(2) := '65722E7574696C203D207B0D0A2020202020202020224D617022203A206E756C6C0D0A202020207D3B0D0A7D2928293B0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(1852254024806694)
,p_plugin_id=>wwv_flow_api.id(1822404000443611)
,p_file_name=>'google.api.adapter.js'
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
