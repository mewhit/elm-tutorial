import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as S } from 'mongoose';

export type StudentDocument = Student & Document;

export class CreateStudent {
  @Prop()
  firstName?: string;

  @Prop()
  lastName?: string;

  @Prop()
  nickName: string;

  @Prop()
  email?: string;

  @Prop()
  userId: S.Types.ObjectId;
}

@Schema()
export class Student extends CreateStudent {
  @Prop()
  id: string;
}

export const StudentSchema = SchemaFactory.createForClass(Student);
