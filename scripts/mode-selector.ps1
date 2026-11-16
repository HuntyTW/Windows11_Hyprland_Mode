Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Выбор режима" Height="340" Width="520"
        WindowStartupLocation="CenterScreen"
        Topmost="True" ResizeMode="NoResize"
        WindowStyle="None" AllowsTransparency="True"
        Background="Transparent">
    <Border Background="#1e1e2e" CornerRadius="16" BorderBrush="#45475a" BorderThickness="2" Padding="24">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Close / Skip Button -->
            <Button Name="BtnClose" Content="✕" HorizontalAlignment="Right" VerticalAlignment="Top"
                    Foreground="#6c7086" Background="Transparent" BorderThickness="0"
                    FontSize="16" FontWeight="Bold" Cursor="Hand" Margin="0,-10,-10,0" Width="30" Height="30"/>

            <!-- Header -->
            <TextBlock Grid.Row="0" Text="Добро пожаловать!" FontSize="22" FontWeight="Bold" Foreground="#cdd6f4" HorizontalAlignment="Center" Margin="0,0,0,4"/>
            <TextBlock Grid.Row="1" Text="Выбери профиль рабочего пространства" FontSize="13" Foreground="#a6adc8" HorizontalAlignment="Center" Margin="0,0,0,22"/>

            <!-- Choices Grid -->
            <Grid Grid.Row="2">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="18"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Dev Mode Card -->
                <Button Name="BtnDev" Grid.Column="0" Background="#181825" BorderThickness="1.5" BorderBrush="#89b4fa" Cursor="Hand">
                    <Button.Resources>
                        <Style TargetType="Border">
                            <Setter Property="CornerRadius" Value="12"/>
                        </Style>
                    </Button.Resources>
                    <StackPanel VerticalAlignment="Center" Margin="12">
                        <TextBlock Text="🚀" FontSize="38" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                        <TextBlock Text="РАЗРАБОТКА" FontSize="15" FontWeight="Bold" Foreground="#89b4fa" HorizontalAlignment="Center"/>
                        <TextBlock Text="GlazeWM + Zebar&#x0a;Hyprland-окружение&#x0a;Обои: Dev" FontSize="11" Foreground="#bac2de" TextAlignment="Center" Margin="0,8,0,0" LineHeight="16"/>
                    </StackPanel>
                </Button>

                <!-- Chill Mode Card -->
                <Button Name="BtnChill" Grid.Column="2" Background="#181825" BorderThickness="1.5" BorderBrush="#a6e3a1" Cursor="Hand">
                    <Button.Resources>
                        <Style TargetType="Border">
                            <Setter Property="CornerRadius" Value="12"/>
                        </Style>
                    </Button.Resources>
                    <StackPanel VerticalAlignment="Center" Margin="12">
                        <TextBlock Text="☕" FontSize="38" HorizontalAlignment="Center" Margin="0,0,0,10"/>
                        <TextBlock Text="ОТДЫХ" FontSize="15" FontWeight="Bold" Foreground="#a6e3a1" HorizontalAlignment="Center"/>
                        <TextBlock Text="Обычный стол&#x0a;Плавающие окна&#x0a;Обои: Chill" FontSize="11" Foreground="#bac2de" TextAlignment="Center" Margin="0,8,0,0" LineHeight="16"/>
                    </StackPanel>
                </Button>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Find elements
$btnDev = $window.FindName("BtnDev")
$btnChill = $window.FindName("BtnChill")
$btnClose = $window.FindName("BtnClose")

$choice = $null

# Drag window with mouse
$window.Add_MouseDown({
    if ($_.ChangedButton -eq [System.Windows.Input.MouseButton]::Left) {
        $window.DragMove()
    }
})

# Close on Esc
$window.Add_KeyDown({
    if ($_.Key -eq [System.Windows.Input.Key]::Escape) {
        $window.Close()
    }
})

$btnClose.Add_Click({
    $window.Close()
})

$btnDev.Add_Click({
    $script:choice = "dev"
    $window.Close()
})

$btnChill.Add_Click({
    $script:choice = "chill"
    $window.Close()
})

# Show modal dialog
$window.ShowDialog() | Out-Null

# Execute selected action
$scriptsPath = "$HOME\scripts"
if ($choice -eq "dev") {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptsPath\dev-mode.ps1`""
} elseif ($choice -eq "chill") {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptsPath\chill-mode.ps1`""
}
