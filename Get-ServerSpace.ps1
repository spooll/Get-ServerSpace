<#
.SYNOPSIS
    Function to get Total Sum of Disks, Disks free space or each Disk separate.
.DESCRIPTION
    You don`t need edit this script, but run Function in Powershell console with Server local admin privileges.
    You can get each disk total and free space on server that you point, or total sum of all disks space.
.PARAMETER Server
    Mandatory param, to point the target server.
.PARAMETER Total
    Gets total sum of all server disks and free space.

    ServerName Label      TotalSpace(GB) FreeSpace(GB)
    ---------- -----      -------------- -------------
    s-wsus-007                        59            28
    s-wsus-007 New Volume           1515           709


    PSComputerName : s-wsus-007
    Property       : TotalSpace(GB)
    Sum            : 1574

    PSComputerName : s-wsus-007
    Property       : FreeSpace(GB)
    Sum            : 737



.EXAMPLE
    Get-ServerSpace -Server s-wsus-007
    Get-ServerSpace -Server s-wsus-007 -Total
#>

function global:Get-ServerSpace {

    param (
        [Parameter(Mandatory)]
        [string]$Server,
        [switch]$Total)
    
    if ($Server -and !$Total)
    {
        Invoke-Command $Server {Get-WmiObject -Namespace "root/cimv2" -Class Win32_Volume |Where-Object { $_.Capacity -gt 1111111111 -and ($_.DriveType -eq 2 -or $_.DriveType -eq 3) }| Select-Object -Property Label,@{'Name' = 'TotalSpace(GB)'; Expression= { [int]($_.Capacity / 1GB) }},@{'Name' = 'FreeSpace(GB)'; Expression= { [int]($_.FreeSpace / 1GB) }}} |Sort-Object "TotalSpace(GB)"| Format-Table @{n="ServerName"; e={$_.PSComputerName}},Label,"TotalSpace(GB)","FreeSpace(GB)" 
    }
    
    
    if ($Server -and $Total)
    {
        Invoke-Command $Server {Get-WmiObject -Namespace "root/cimv2" -Class Win32_Volume |Where-Object { $_.Capacity -gt 1111111111 -and ($_.DriveType -eq 2 -or $_.DriveType -eq 3) }| Select-Object -Property Label,@{'Name' = 'TotalSpace(GB)'; Expression= { [int]($_.Capacity / 1GB) }},@{'Name' = 'FreeSpace(GB)'; Expression= { [int]($_.FreeSpace / 1GB) }}| Measure-Object -Property 'TotalSpace(GB)','FreeSpace(GB)' -Sum} | fl PSComputerName, Property, Sum
    }
    
    }
