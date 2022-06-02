import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as S } from 'mongoose';
import { CompileResult, fromMongo } from '../../elm/test-result.schema';

export interface IExcerciseSolution {
  excerciseId: string;
  userId: string;
  code: string;
  results: CompileResult[];
}

export type ExcerciseSolutionDocument = ExcerciseSolution & Document;

export class CreateExcerciseSolution {
  @Prop()
  excerciseId: string;

  @Prop()
  userId: string;

  @Prop()
  code: string;
}

@Schema()
export class ExcerciseSolution extends CreateExcerciseSolution {
  _id: S.Types.ObjectId;

  @Prop({ type: {}, default: [], transform: fromMongo })
  results: CompileResult[];

  get id() {
    return this._id;
  }
}

export const ExcerciseSolutionSchema =
  SchemaFactory.createForClass(ExcerciseSolution);
