//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <local_auth_windows/local_auth_plugin.h>
#include <network_info_plus/network_info_plus_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  LocalAuthPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LocalAuthPlugin"));
  NetworkInfoPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NetworkInfoPlusWindowsPlugin"));
}
