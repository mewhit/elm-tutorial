import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Schema as S } from 'mongoose';

export type UserDocument = User & Document;

export class CreateUser {
  @Prop()
  githubId: string;

  @Prop()
  username: string;
}

@Schema()
export class User extends CreateUser {
  _id: S.Types.ObjectId;

  get id() {
    return this._id;
  }
}

export const UserSchema = SchemaFactory.createForClass(User);
