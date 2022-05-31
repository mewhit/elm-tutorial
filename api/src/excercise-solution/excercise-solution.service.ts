import { Injectable } from '@nestjs/common';

import * as fs from 'fs';
import * as Either from 'fp-ts/Either';
import { CompileResult } from '../elm/test-result.model';
import { ElmService } from '../elm/elm.service';
import { copyFolderRecursiveSync, createTempsDir } from '../libs/FileHelper';
import {
  CreateExcerciseSolution,
  ExcerciseSolution,
  ExcerciseSolutionDocument,
} from './schemas/excercise.schema';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { newGuid } from '../libs/GuidHelper';

@Injectable()
export class ExcerciseSolutionService {
  constructor(
    private readonly elmService: ElmService,
    @InjectModel(ExcerciseSolution.name)
    private solutionRepo: Model<ExcerciseSolutionDocument>,
  ) {}

  async compile(
    solution: CreateExcerciseSolution,
  ): Promise<Either.Either<string, ExcerciseSolution>> {
    createTempsDir();
    const dirPath = `temps/${newGuid()}`;

    const excercise = `excercise-${solution.excerciseId}`;

    try {
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath);
      }
      copyFolderRecursiveSync(`template/${excercise}`, `${dirPath}`);
      fs.appendFileSync(`${dirPath}/${excercise}/src/Main.elm`, solution.code);

      const excercisePath = `${dirPath}/${excercise}`;

      const result = this.elmService.test(excercisePath);
      return Either.map((r: readonly CompileResult[]) => ({
        id: '',
        excerciseId: solution.excerciseId,
        userId: solution.userId,
        results: [...r],
        code: solution.code,
      }))(result);
    } catch (err) {
      fs.rmdirSync(`${dirPath}`, { recursive: true });
      throw err;
    }
  }

  private async save(solution: CreateExcerciseSolution) {
    if (!solution.userId) return;
    const mSolution = this.solutionRepo.findOne({
      userId: solution.userId,
      excerciseId: solution.excerciseId,
    });

    if (!mSolution) {
      await new this.solutionRepo(solution).save();
    } else {
      await this.solutionRepo
        .updateOne(
          {
            userId: solution.userId,
            excerciseId: solution.excerciseId,
          },
          solution,
        )
        .exec();
    }
  }
}
