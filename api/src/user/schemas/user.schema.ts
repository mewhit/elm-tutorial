import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

export class CreateUser {
  @Prop()
  githubId: string;

  @Prop()
  username: string;
}

@Schema()
export class User extends CreateUser {
  @Prop()
  _id: string;
}

export const UserSchema = SchemaFactory.createForClass(User);
