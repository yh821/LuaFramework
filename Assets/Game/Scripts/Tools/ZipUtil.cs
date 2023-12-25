using System;
using System.IO;
using System.Text;
using ICSharpCode.SharpZipLib.Checksums;
using ICSharpCode.SharpZipLib.Zip;

public static class ZipUtil
{
	/// <summary>
	/// 压缩文件
	/// </summary>
	/// <param name="srcPath">源文件(绝对路径)</param>
	/// <param name="dstPath">目标路径(绝对路径)</param>
	/// <param name="zipName">压缩包名(默认同源文件)</param>
	/// <param name="action">压缩完成后回调</param>
	/// <param name="compressionLevel">压缩等级[0-9]</param>
	/// <param name="blockSize">缓存大小</param>
	/// <param name="isEncrypt">是否加密</param>
	public static void ZipFile(string srcPath, string dstPath, string zipName = "", Action action = null,
		int compressionLevel = 5, int blockSize = 2048, string password = "")
	{
		ZipConstants.DefaultCodePage = Encoding.UTF8.CodePage;
		if (!File.Exists(srcPath))
			throw new FileNotFoundException("不存在文件: " + srcPath);

		srcPath = srcPath.Replace(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
		dstPath = dstPath.Replace(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);

		string zipPath;
		if (string.IsNullOrEmpty(zipName))
		{
			var fileName = new FileInfo(srcPath).Name;
			zipPath = dstPath + "/" + fileName.Substring(0, fileName.LastIndexOf('.')) + ".zip";
		}
		else
			zipPath = dstPath + "/" + zipName + ".zip";

		using var zipFile = File.Create(zipPath);
		using (var zipStream = new ZipOutputStream(zipFile))
		{
			using (var fileStream = new FileStream(srcPath, FileMode.Open, FileAccess.Read))
			{
				var fileName = srcPath.Substring(srcPath.LastIndexOf(Path.AltDirectorySeparatorChar) + 1);
				var zipEntry = new ZipEntry(fileName);
				if (!string.IsNullOrEmpty(password)) zipStream.Password = password;
				zipStream.PutNextEntry(zipEntry);
				zipStream.SetLevel(compressionLevel);
				var buffer = new byte[blockSize];
				try
				{
					var sizeRead = 0;
					do
					{
						sizeRead = fileStream.Read(buffer, 0, buffer.Length);
						zipStream.Write(buffer, 0, sizeRead);
					} while (sizeRead > 0);
				}
				catch (Exception ex)
				{
					throw ex;
				}

				fileStream.Close();
			}

			zipStream.Close();
		}

		zipFile.Close();
		action?.Invoke();
	}


	/// <summary>
	/// 压缩文件夹
	/// </summary>
	/// <param name="srcFolder">源文件夹(绝对路径)</param>
	/// <param name="dstPath">目标路径(绝对路径)</param>
	/// <param name="zipName">压缩包名(默认同源文件)</param>
	/// <param name="action">压缩完成后回调</param>
	/// <param name="compressionLevel">压缩等级[0-9]</param>
	/// <param name="blockSize">缓存大小</param>
	/// <param name="isEncrypt">是否加密</param>
	public static void ZipDirectory(string srcFolder, string dstPath, string zipName = "", Action action = null,
		string password = "")
	{
		ZipConstants.DefaultCodePage = Encoding.UTF8.CodePage;
		if (!Directory.Exists(srcFolder))
			throw new FileNotFoundException("不存在目录: " + srcFolder);

		srcFolder = srcFolder.Replace(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
		dstPath = dstPath.Replace(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);

		string zipPath;
		if (string.IsNullOrEmpty(zipName))
			zipPath = dstPath + "/" + new DirectoryInfo(srcFolder).Name + ".zip";
		else
			zipPath = dstPath + "/" + zipName + ".zip";

		using var zipFile = File.Create(zipPath);
		using (var zipStream = new ZipOutputStream(zipFile))
		{
			if (!string.IsNullOrEmpty(password)) zipStream.Password = password;
			ZipDir(srcFolder, zipStream, "");
		}

		zipFile.Close();
		action?.Invoke();
	}

	private static void ZipDir(string srcDir, ZipOutputStream stream, string parentPath)
	{
		if (srcDir[srcDir.Length - 1] != Path.DirectorySeparatorChar)
			srcDir += Path.DirectorySeparatorChar;
		var crc = new Crc32();
		var files = Directory.GetFileSystemEntries(srcDir);
		foreach (var file in files)
		{
			if (Directory.Exists(file))
			{
				var pPath = parentPath;
				pPath += file.Substring(file.LastIndexOf(Path.AltDirectorySeparatorChar) + 1);
				pPath += Path.AltDirectorySeparatorChar;
				ZipDir(file, stream, pPath);
			}
			else
			{
				using var fileSteam = File.OpenRead(file);
				var buffer = new byte[fileSteam.Length];
				fileSteam.Read(buffer, 0, buffer.Length);
				var fileName = parentPath + file.Substring(file.LastIndexOf(Path.AltDirectorySeparatorChar) + 1);
				var entry = new ZipEntry(fileName) {DateTime = DateTime.Now, Size = fileSteam.Length};
				fileSteam.Close();
				crc.Reset();
				crc.Update(buffer);
				entry.Crc = crc.Value;
				stream.PutNextEntry(entry);
				stream.Write(buffer, 0, buffer.Length);
			}
		}
	}

	/// <summary>
	/// 解压zip文件
	/// </summary>
	/// <param name="zipFile"></param>
	/// <param name="dstPath"></param>
	/// <param name="action"></param>
	/// <param name="password"></param>
	/// <param name="overWrite"></param>
	public static void UnZip(string zipFile, string dstPath, Action action = null, string password = "",
		bool overWrite = true)
	{
		ZipConstants.DefaultCodePage = Encoding.UTF8.CodePage;
		zipFile = zipFile.Replace(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
		dstPath = dstPath.Replace(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
		if (!File.Exists(zipFile))
			throw new FileNotFoundException("不存在文件: " + zipFile);
		if (!Directory.Exists(dstPath))
			throw new FileNotFoundException("不存在目录: " + dstPath);
		if (!dstPath.EndsWith("/"))
			dstPath += "/";

		using (var zipStream = new ZipInputStream(File.OpenRead(zipFile)))
		{
			if (!string.IsNullOrEmpty(password)) zipStream.Password = password;
			ZipEntry entry;
			while ((entry = zipStream.GetNextEntry()) != null)
			{
				var dirName = "";
				var pathToZip = entry.Name;
				if (!string.IsNullOrEmpty(pathToZip))
					dirName = Path.GetDirectoryName(pathToZip) + "/";
				var fileName = Path.GetFileName(pathToZip);
				Directory.CreateDirectory(dstPath + dirName);
				if (string.IsNullOrEmpty(fileName)) continue;
				var fullPath = dstPath + dirName + fileName;
				if (File.Exists(fullPath) && overWrite || !File.Exists(fullPath))
				{
					using var fileStream = File.Create(fullPath);
					var data = new byte[2048];
					while (true)
					{
						var size = zipStream.Read(data, 0, data.Length);
						if (size > 0)
							fileStream.Write(data, 0, size);
						else
							break;
					}
					fileStream.Close();
				}
			}
			zipStream.Close();
		}
		action?.Invoke();
	}
}