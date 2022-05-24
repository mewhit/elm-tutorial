import { Module } from '@nestjs/common';
import { ElmModule } from './elm/elm.module';
import { ExcerciseModule } from './excercise/excercise.module';
import { GraphQLModule } from '@nestjs/graphql';
import {
  ApolloFederationDriver,
  ApolloFederationDriverConfig,
} from '@nestjs/apollo';
import { ExcerciseSolutionModule } from './excercise-solution/excercise-solution.module';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import githubAuthConfig from './auth/github/github.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [
        () => ({
          callbackURL: `${process.env.ELM_TUTORIAL_URL}`,
          jwt: {
            secret: process.env.JWT_SECRET,
          },
          mongo: {
            uri: process.env.MONGO_URI,
          },
        }),
        githubAuthConfig,
      ],
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: config.get('mongo.uri'),
      }),
    }),
    GraphQLModule.forRoot<ApolloFederationDriverConfig>({
      driver: ApolloFederationDriver,

      autoSchemaFile: `${process.cwd()}/src/schema.gql`,
      path: 'graphql',
      buildSchemaOptions: {
        dateScalarMode: 'timestamp',
      },
    }),
    ExcerciseModule,
    ElmModule,
    ExcerciseSolutionModule,
    AuthModule,
    UserModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
