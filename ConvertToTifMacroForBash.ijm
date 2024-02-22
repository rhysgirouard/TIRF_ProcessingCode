arg = getArgument();
output = arg + "/zz_Results"

setBatchMode(true); 
list = getFileList(arg);
for (i = 0; i < list.length-1; i++){
        action(arg, output, list[i]);
}
setBatchMode(false);

eval("script", "System.exit(0);");

function action(input, output, filename) {
		fullFilePath = input + "/" + filename;
		openString = "open=" + fullFilePath;
        run("Bio-Formats Windowless Importer", openString);
        saveAs("Tiff", output + "/" + filename);
        close();
}