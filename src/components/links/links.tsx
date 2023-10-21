import React from 'react';
import { Divider } from '../extras/divider';
import { WriteUpLink } from './write-up-link';
import { Donate } from './donate';
import { GithubLink } from './github-link';

export const Links: React.FC = () => {
  return (
    <div>
      <Divider />
      <GithubLink />
      <Divider />
      <WriteUpLink />
      <Divider />
      <Donate />
    </div>
  );
};
