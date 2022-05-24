export interface GithubAuthConfig {
  clientID: string;
  clientSecret: string;
  callbackURL: string;
}

const githubAuthConfig = () => ({
  githubAuth: {
    clientID: process.env.GITHUB_CLIENT_ID,
    clientSecret: process.env.GITHUB_CLIENT_SECRET,
  },
});

export default githubAuthConfig;
