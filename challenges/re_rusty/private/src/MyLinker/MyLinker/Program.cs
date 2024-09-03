using System;
using System.Diagnostics;
using System.IO;
using System.Linq;

namespace MyLinker
{
    class Program
    {
        static void Main(string[] args)
        {
            var processStartInfo = new ProcessStartInfo
            {
                FileName =
                    "c:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Professional\\SDK\\ScopeCppSDK\\vc15\\VC\\bin\\link.exe",
                UseShellExecute = false,
            };
            string fileName = args[0].Substring(1);
            string linker = @"/STUB:c:\sources\github\justCTF2020\challenges\re_rusty\src\DOS-STUB\DOSSTUB.EXE";
            string pdb = @"/PDBSTRIPPED";
            if (File.Exists(fileName))
            {
                processStartInfo.Arguments = args[0];
                string options = File.ReadAllText(args[0].Substring(1));
                options = pdb + Environment.NewLine+linker +
                          Environment.NewLine + options;
                File.WriteAllText(args[0].Substring(1), options);
            }
            else
            {
                processStartInfo.Arguments = pdb + " " + linker + " " + args.Aggregate((x, y) => x + " " + y);
                processStartInfo.Arguments = processStartInfo.Arguments.Replace("/DEBUG", "");
            }

            var process = Process.Start(processStartInfo);
            process.WaitForExit();
        }
    }
}
