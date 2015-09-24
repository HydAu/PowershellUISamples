add-Type @"

public class IndexerDemo
{
    private int _w;
    private int _x;
    private int _y;
    private int _z;

    public int this[int idx]
    {
        get
        {
            if (idx == 0)
                return _w;
            else if (idx == 1)
                return _x;
            else if (idx == 2)
                return _y;
            else
                return _z;
        }

        set
        {
            if (idx == 0)
                _w = value;
            else if (idx == 1)
                _x = value;
            else if (idx == 2)
                _y = value;
            else if (idx == 3)
                _z = value;
        }
    }
}
"@
$indexer_demo  = new-object  IndexerDemo
0..4 | foreach-object {
  $i = $_
  $indexer_demo[$i] = $i*40
}

0..4 | foreach-object {
  Write-output ('$num[{0}] = {1}' -f $_, $indexer_demo[$_])
}

