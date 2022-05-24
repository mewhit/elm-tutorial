import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateUser, User, UserDocument } from './schemas/user.schema';

@Injectable()
export class UserService {
  constructor(@InjectModel(User.name) private userRepo: Model<UserDocument>) {}

  findByGitHubId(id: string) {
    return this.userRepo.findOne({ githubId: id }).exec();
  }

  create(user: CreateUser) {
    const newUser = new this.userRepo(user);

    return newUser.save();
  }
}
