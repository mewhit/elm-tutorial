import { Injectable } from '@nestjs/common';

import * as fs from 'fs';
import * as path from 'path';
import * as Either from 'fp-ts/Either';
import { CompileResult } from '../elm/test-result.model';
import { ElmService } from '../elm/elm.service';

const newGuid = () => {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0,
      v = c == 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
};

function copyFileSync(source: string, target: string) {
  let targetFile = target;

  // If target is a directory, a new file with the same name will be created
  if (fs.existsSync(target)) {
    if (fs.lstatSync(target).isDirectory()) {
      targetFile = path.join(target, path.basename(source));
    }
  }

  fs.writeFileSync(targetFile, fs.readFileSync(source));
}

function copyFolderRecursiveSync(source: string, target: string) {
  let files = [];

  // Check if folder needs to be created or integrated
  const targetFolder = path.join(target, path.basename(source));
  if (!fs.existsSync(targetFolder)) {
    fs.mkdirSync(targetFolder);
  }

  // Copy
  if (fs.lstatSync(source).isDirectory()) {
    files = fs.readdirSync(source);
    files.forEach(function (file) {
      const curSource = path.join(source, file);
      if (fs.lstatSync(curSource).isDirectory()) {
        copyFolderRecursiveSync(curSource, targetFolder);
      } else {
        copyFileSync(curSource, targetFolder);
      }
    });
  }
}

const createTempsDir = () => {
  if (!fs.existsSync('temps')) {
    fs.mkdirSync('temps');
  }
};
@Injectable()
export class ExcerciseService {
  constructor(private readonly elmService: ElmService) {}

  compile(
    id: string,
    str: string,
  ): Either.Either<string, readonly CompileResult[]> {
    createTempsDir();
    const dirPath = `temps/${newGuid()}`;

    const excercise = `excercise-${id}`;

    try {
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath);
      }
      copyFolderRecursiveSync(`template/${excercise}`, `${dirPath}`);
      fs.appendFileSync(`${dirPath}/${excercise}/src/Main.elm`, str);

      const excercisePath = `${dirPath}/${excercise}`;

      return this.elmService.test(excercisePath);
    } catch (err) {
      fs.rmdirSync(`${dirPath}`, { recursive: true });
      throw err;
    }
  }
}
