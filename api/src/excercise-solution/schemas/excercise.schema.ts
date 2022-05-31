import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { CompileResult } from '../../elm/test-result.schema';

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
  @Prop()
  id: string;

  @Prop()
  results: CompileResult[];
}

export const ExcerciseSolutionSchema =
  SchemaFactory.createForClass(ExcerciseSolution);
