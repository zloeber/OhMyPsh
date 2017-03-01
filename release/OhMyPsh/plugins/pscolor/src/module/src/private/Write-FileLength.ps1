# Helper method to write file length in a more human readable format
function Write-FileLength
{
    param ($length)

    if ($length -eq $null)
    {
        return ""
    }
    elseif ($length -ge 1GB)
    {
        return ($length / 1GB).ToString("F") + 'GB'
    }
    elseif ($length -ge 1MB)
    {
        return ($length / 1MB).ToString("F") + 'MB'
    }
    elseif ($length -ge 1KB)
    {
        return ($length / 1KB).ToString("F") + 'KB'
    }

    return $length.ToString() + '  '
}