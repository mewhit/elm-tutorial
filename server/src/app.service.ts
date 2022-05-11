import { Injectable, StreamableFile } from '@nestjs/common';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';
import { Readable, Stream } from 'stream';

const newGuid = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = Math.random() * 16 | 0,
      v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

function copyFileSync(source, target) {

  var targetFile = target;

  // If target is a directory, a new file with the same name will be created
  if (fs.existsSync(target)) {
    if (fs.lstatSync(target).isDirectory()) {
      targetFile = path.join(target, path.basename(source));
    }
  }

  fs.writeFileSync(targetFile, fs.readFileSync(source));
}

function copyFolderRecursiveSync(source, target) {
  var files = [];

  // Check if folder needs to be created or integrated
  var targetFolder = path.join(target, path.basename(source));
  if (!fs.existsSync(targetFolder)) {
    fs.mkdirSync(targetFolder);
  }

  // Copy
  if (fs.lstatSync(source).isDirectory()) {
    files = fs.readdirSync(source);
    files.forEach(function (file) {
      var curSource = path.join(source, file);
      if (fs.lstatSync(curSource).isDirectory()) {
        copyFolderRecursiveSync(curSource, targetFolder);
      } else {
        copyFileSync(curSource, targetFolder);
      }
    });
  }
}

const createTempsDir = () => {
  if (!fs.existsSync("temps")) {
    fs.mkdirSync("temps");
  }
}

@Injectable()
export class AppService {
  compile(str: string): [string, string] {
    createTempsDir()
    const dirPath = `temps/${newGuid()}`

    try {
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath);
      }
      copyFolderRecursiveSync('template/excercise-1', `${dirPath}`)
      fs.appendFileSync(`${dirPath}/excercise-1/src/Main.elm`, str);

      const excercisePath = `${dirPath}/excercise-1`

      try {
        execSync(`cd ${excercisePath} && elm make ./src/Main.elm`)
      } catch (err) {
        fs.writeFileSync(`${excercisePath}/index.html`, `<p style="white-space: pre-wrap">${err.stderr.toString()}</p>`)
      }

      try {
        const result = execSync(`cd ${excercisePath} && elm-test`)
        fs.appendFileSync(`${excercisePath}/index.html`, `<p style="white-space: pre-wrap">${result.toString()}</p>`)
      } catch (err) {
        fs.writeFileSync(`${excercisePath}/index.html`, `<p style="white-space: pre-wrap">${err.stderr.toString()}</p>`)
      }

      return [excercisePath, `${excercisePath}/index.html`]
    } catch (err) {
      fs.rmdirSync(`${dirPath}`, { recursive: true })
      return err;
    }
  }




}
