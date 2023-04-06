# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

# don't warn me
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

workspace 'AEPMessaging'
project 'AEPMessaging.xcodeproj'

pod 'SwiftLint', '0.44.0'

# ==================
# SHARED POD GROUPS
# ==================
def lib_main
    pod 'AEPCore', :git => 'https://github.com/sbenedicadb/aepsdk-core-ios.git', :branch => 'dev-v3.9.0'
    pod 'AEPServices'
    pod 'AEPRulesEngine'
end

def lib_dev
    pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.7.3'
    pod 'AEPServices', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.7.3'
    pod 'AEPRulesEngine', :git => 'https://github.com/adobe/aepsdk-rulesengine-ios.git', :branch => 'main'
end

def app_main
    pod 'AEPCore', :git => 'https://github.com/sbenedicadb/aepsdk-core-ios.git', :branch => 'dev-v3.9.0'
    pod 'AEPServices'
    pod 'AEPLifecycle'
    pod 'AEPRulesEngine'
    pod 'AEPSignal'
    pod 'AEPEdge'
    pod 'AEPEdgeConsent'
    pod 'AEPEdgeIdentity'
    pod 'AEPAssurance'
end

def app_dev
    pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.7.3'
    pod 'AEPServices', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.7.3'
    pod 'AEPLifecycle', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.7.3'
    pod 'AEPSignal', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.7.3'
    pod 'AEPRulesEngine', :git => 'https://github.com/adobe/aepsdk-rulesengine-ios.git', :branch => 'main'
    pod 'AEPEdge', :git => 'https://github.com/adobe/aepsdk-edge-ios.git', :branch => 'main'
    pod 'AEPEdgeConsent'
    pod 'AEPEdgeIdentity', :git => 'https://github.com/adobe/aepsdk-edgeidentity-ios.git', :branch => 'main'
    pod 'AEPAnalytics'
    pod 'AEPAssurance', :git => 'https://github.com/adobe/aepsdk-assurance-ios.git', :branch => 'main'
end

# ==================
# TARGET DEFINITIONS
# ==================
target 'AEPMessaging' do
  lib_main
end

target 'MessagingDemoApp' do
  app_main
end

target 'MessagingDemoAppObjC' do
  app_main
end

target 'UnitTests' do
  lib_main
end

target 'FunctionalTests' do
  app_main
end

target 'E2EFunctionalTests' do
  app_main
end

target 'FunctionalTestApp' do
  app_main
end

target 'E2EFunctionalTestApp' do
  app_main
end
