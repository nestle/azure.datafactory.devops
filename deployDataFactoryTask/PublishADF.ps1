[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Publishes Azure Data Factory using code from JSON files specified DAC publish profile from your solution.

	.DESCRIPTION
    Publishes Azure Data Factory using code from JSON files specified DAC publish profile from your solution.

    Script written by (c) Kamil Nowinski (SQLPlayer.net blog), 2020 for Azure DevOps extension
    Source code and documentation: https://github.com/SQLPlayer/azure.datafactory.devops
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    Depends on PowerShell module azure.datafactory.tools 
    written by (c) Kamil Nowinski, 2020 https://github.com/SQLPlayer/azure.datafactory.tools
#>

Trace-VstsEnteringInvocation $MyInvocation
try {

    # import required modules
	$ModulePathADFT = "$PSScriptRoot\ps_modules\azure.datafactory.tools\azure.datafactory.tools.psd1"
    $config = Import-PowerShellDataFile $ModulePathADFT
    Write-Output "Azure.DataFactory.Tools version: $($config.ModuleVersion)"

    #Get-Module -ListAvailable

    $ModulePathAcc = "$PSScriptRoot\ps_modules\Az.Accounts\az.accounts.psd1"
    Import-Module -Name $ModulePathAcc
	$ModulePathADF = "$PSScriptRoot\ps_modules\Az.DataFactory\az.datafactory.psd1"
    Import-Module -Name $ModulePathADF
    Import-Module -Name $ModulePathADFT


    . "$PSScriptRoot\Utility.ps1"

    #$serviceName = Get-VstsInput -Name ConnectedServiceNameARM -Require
    $serviceName = Get-VstsInput -Name ConnectedServiceName -Require
    $endpointObject = Get-VstsEndpoint -Name $serviceName -Require
    $endpoint = ConvertTo-Json $endpointObject
    #$CoreAzArgument = "-endpoint '$endpoint'"
    . "$PSScriptRoot\CoreAz.ps1" -endpoint $endpoint


    #Get-Module -ListAvailable

    # Get inputs params
    [string]$RootFolder = Get-VstsInput -Name "DataFactoryCodePath" -Require;
    [string]$DataFactoryName = Get-VstsInput -Name "DataFactoryName" -Require;
    [string]$ResourceGroupName = Get-VstsInput -Name  "ResourceGroupName" -Require;
    [string]$Location = Get-VstsInput -Name "Location" -Require;

    $global:ErrorActionPreference = 'Stop';

    Write-Host "Invoking Publish-AdfV2FromJson (https://github.com/SQLPlayer/azure.datafactory.tools) with the following parameters:";
    Write-Host "DataFactoryName:    $DataFactoryName";
    Write-Host "RootFolder:         $RootFolder";
    Write-Host "ResourceGroupName:  $ResourceGroupName";
    Write-Host "Location:           $Location";

    Publish-AdfV2FromJson -RootFolder "$RootFolder" `
        -ResourceGroupName "$ResourceGroupName" `
        -DataFactoryName "$DataFactoryName" `
        -Location "$Location"


} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

