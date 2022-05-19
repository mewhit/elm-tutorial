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

@Module({
  imports: [
    ConfigModule.forRoot({
      load: [
        () => ({
          mongo: {
            uri: process.env.MONGO_URI,
          },
        }),
      ],
    }),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        console.log(config);
        return {
          uri: config.get('mongo.uri'),
        };
      },
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
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
