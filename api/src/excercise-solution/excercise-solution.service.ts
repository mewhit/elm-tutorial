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
  IExcerciseSolution,
} from './schemas/excercise.schema';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { newGuid } from '../libs/GuidHelper';
import { string } from 'fp-ts';

@Injectable()
export class ExcerciseSolutionService {
  constructor(
    private readonly elmService: ElmService,
    @InjectModel(ExcerciseSolution.name)
    private solutionRepo: Model<ExcerciseSolutionDocument>,
  ) {}

  async getAllByUserId(userId: string) {
    const t = await this.solutionRepo.find({ userId }).exec();
    return t;
  }

  async compile(
    solution: CreateExcerciseSolution,
  ): Promise<Either.Either<string, IExcerciseSolution>> {
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
      const t = await this.save(solution, result);
      return Either.map(() => t)(result);
    } catch (err) {
      fs.rmdirSync(`${dirPath}`, { recursive: true });
      throw err;
    }
  }

  private async save(
    solution: CreateExcerciseSolution,
    result: Either.Either<string, readonly CompileResult[]>,
  ): Promise<IExcerciseSolution> {
    const excerciseSolution = {
      ...solution,
      results: Either.fold<string, readonly CompileResult[], CompileResult[]>(
        () => [],
        (r: CompileResult[]) => [...r],
      )(result),
    };

    if (!solution.userId) return excerciseSolution;
    const mSolution = await this.solutionRepo
      .findOne({
        userId: solution.userId,
        excerciseId: solution.excerciseId,
      })
      .exec();

    if (!mSolution) {
      await new this.solutionRepo(excerciseSolution).save();
    } else {
      await this.solutionRepo
        .updateOne(
          {
            userId: solution.userId,
            excerciseId: solution.excerciseId,
          },
          excerciseSolution,
        )
        .exec();
    }

    return await this.solutionRepo
      .findOne({
        userId: solution.userId,
        excerciseId: solution.excerciseId,
      })
      .exec();
  }
}
