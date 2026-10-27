param([string]$Out)
Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

function P($x, $y) { New-Object System.Drawing.PointF([single]$x, [single]$y) }

# Nền gradient hoàng hôn
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush((P 0 0), (P $size $size),
    [System.Drawing.Color]::FromArgb(255, 236, 64, 122), [System.Drawing.Color]::FromArgb(255, 255, 167, 81))
$g.FillRectangle($bg, 0, 0, $size, $size)

# Quầng sáng mềm sau nhân vật
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(232, 230, 560, 560)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor = [System.Drawing.Color]::FromArgb(90, 255, 240, 200)
$glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 240, 200))
$g.FillPath($glow, $glowPath)

function New-Pen($color, $width) {
    $p = New-Object System.Drawing.Pen($color, [single]$width)
    $p.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $p.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $p
}

# Khung ngắm camera (4 góc)
$white = [System.Drawing.Color]::White
$frame = New-Pen $white 34
$a = 160; $b = 864; $l = 120
foreach ($c in @(@($a, $a, 1, 1), @($b, $a, -1, 1), @($a, $b, 1, -1), @($b, $b, -1, -1))) {
    $x = $c[0]; $y = $c[1]; $dx = $c[2]; $dy = $c[3]
    $g.DrawLines($frame, [System.Drawing.PointF[]]@((P $x ($y + $dy * $l)), (P $x $y), (P ($x + $dx * $l) $y)))
}

# Nhân vật đang bật nhảy: ghép mọi bộ phận thành MỘT khối để không lộ đường nối
$fig = New-Object System.Drawing.Drawing2D.GraphicsPath([System.Drawing.Drawing2D.FillMode]::Winding)
function Add-Limb($points, $width) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddLines([System.Drawing.PointF[]]$points)
    $p.Widen((New-Pen $white $width))
    $fig.AddPath($p, $false)
}
$fig.AddEllipse(452, 236, 120, 130)                                        # đầu
$fig.AddPolygon([System.Drawing.PointF[]]@((P 446 404), (P 578 404), (P 552 560), (P 568 612), (P 456 612), (P 472 560)))   # thân
$fig.AddEllipse(420, 390, 60, 60); $fig.AddEllipse(544, 390, 60, 60)       # vai
Add-Limb @((P 452 420), (P 380 340), (P 330 250)) 44                       # tay trái
Add-Limb @((P 572 420), (P 644 340), (P 694 250)) 44                       # tay phải
Add-Limb @((P 488 596), (P 466 708), (P 452 810)) 54                       # chân trụ
Add-Limb @((P 538 596), (P 592 704), (P 680 760)) 54                       # chân co

$shadow = $fig.Clone()
$m = New-Object System.Drawing.Drawing2D.Matrix; $m.Translate(0, 12); $shadow.Transform($m)
$g.FillPath((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(50, 140, 20, 50))), $shadow)
$g.FillPath((New-Object System.Drawing.SolidBrush($white)), $fig)

# Ngôi sao lấp lánh (AI)
function Draw-Sparkle($cx, $cy, $r) {
    $k = $r * 0.22
    $pts = [System.Drawing.PointF[]]@(
        (P $cx ($cy - $r)), (P ($cx + $k) ($cy - $k)), (P ($cx + $r) $cy), (P ($cx + $k) ($cy + $k)),
        (P $cx ($cy + $r)), (P ($cx - $k) ($cy + $k)), (P ($cx - $r) $cy), (P ($cx - $k) ($cy - $k)))
    $g.FillPolygon((New-Object System.Drawing.SolidBrush($white)), $pts)
}
Draw-Sparkle 772 262 62
Draw-Sparkle 712 196 26

$g.Dispose()
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
"saved $Out"
