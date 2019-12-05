# Load Windows Forms & Drawing classes.
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

### SET FOLDER TO WATCH + FILES TO WATCH + SUBFOLDERS YES/NO
Set-ExecutionPolicy RemoteSigned
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = "C:\Users\ryc2016\Documents\solenzara\Solenzaratraces"
    $watcher.Filter = "*.oma"
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true  

### DEFINE ACTIONS AFTER AN EVENT IS DETECTED
    $action = { $path = $Event.SourceEventArgs.FullPath
                $changeType = $Event.SourceEventArgs.ChangeType
				$name = $Event.SourceEventArgs.Name
				$nombre=$name.substring(0,$name.length-4)
                $logline = "$(Get-Date), $changeType, $path, $name"
                Add-content "C:\Trazadora\Historial.txt" -value $logline
				#Remove-Item 'C:\Users\Public\Documents\Trazados\recibidos' -Recurse 
				##### Pop-up
				
# Create base form.
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Tipo de bisel"
$objForm.Size = New-Object System.Drawing.Size(340,240) 
$objForm.StartPosition = "CenterScreen"

# Configure keyboard intercepts for ESC & ENTER.
$objForm.KeyPreview = $True
$objForm.Add_KeyDown({
    if ($_.KeyCode -eq "Enter") 
    {
        $x=$objListBox.SelectedItem
        $objForm.Close()
    }
})
$objForm.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()
    }
})

# Create OK button.
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,160)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "ACEPTAR"
$OKButton.Add_Click({$global:x=$objListBox.SelectedItem;$objForm.Close()})
#$OKButton.Add_Click({$x=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)


$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,160)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "CANCELAR"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(300,40) 
$objLabel.Text = "Seleccione el tipo de montura para el trabajo, $nombre"
$objForm.Controls.Add($objLabel) 

$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,60) 
$objListBox.Size = New-Object System.Drawing.Size(300,20) 
$objListBox.Height = 90

[void] $objListBox.Items.Add("Montura Completa")
[void] $objListBox.Items.Add("Tres piezas")
[void] $objListBox.Items.Add("Ranurada")


$objForm.Controls.Add($objListBox) 

# Force list box to display on top of other windows.
$objForm.TopMost = $true

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()


switch($x){
    "Montura Completa"{Add-content "$path" -value  "ETYP=1"}
    "Tres piezas"{Add-content "$path" -value  "ETYP=2"}
    "Ranurada"{Add-content "$path" -value  "ETYP=3"}
    default{write-warning "Opcion invalida. Goodbye."}

}

#### Cambiar JOB Number


(get-content $path) -replace (select-string "JOB=" $path).line, "JOB=`"$nombre`""| Set-Content $path

####
start-process "C:\Trazadora\enviomail.bat" $name
				

				}   

	
			  
### DECIDE WHICH EVENTS SHOULD BE WATCHED 
   # Register-ObjectEvent $watcher "Created" -Action $action
   # Register-ObjectEvent $watcher "Changed" -Action $action
   # Register-ObjectEvent $watcher "Deleted" -Action $action
    Register-ObjectEvent $watcher "Renamed" -Action $action
    while ($true) {sleep 5}



