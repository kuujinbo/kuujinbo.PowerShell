Set-StrictMode -Version 2.0;

Add-Type @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace ConfigFiles
{
    public class FileFind
    {
        public IEnumerable<string> GetFiles(string path)
        {
            var queue = new Queue<string>();
            queue.Enqueue(path);
            while (queue.Count > 0)
            {
                path = queue.Dequeue();
                try
                {
                    foreach (var subDir in Directory.GetDirectories(path))
                    {
                        queue.Enqueue(subDir);
                    }
                }
                catch (Exception e)
                {
                    Console.Error.WriteLine(e.Message);
                }
                string[] files = null;
                try
                {
                    files = Directory.GetFiles(path).Where(
                        x => x.EndsWith(".exe.config")
                         || x.EndsWith("machine.config")
                    ).ToArray();
                }
                catch (Exception e)
                {
                    Console.Error.WriteLine(e.Message);
                }
                if (files != null)
                {
                    for (int i = 0; i < files.Length; i++) yield return files[i];
                }
            }
        }

    }
}
'@;


