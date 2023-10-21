import { Tabs } from '../../ts/enums/tabs-enum';
import { TabButton } from './tab-button';
import { useCore } from '../../hooks/use-core';

export interface TabNavParameters {
  handleTabChange: (tab: Tabs) => void;
}

export const TabNav = ({ handleTabChange }: TabNavParameters) => {
  const { activeTab, setActiveTab } = useCore();
  return (
    <>
      {Object.values(Tabs).map((tab: Tabs) => (
        <TabButton
          key={tab}
          activeTab={activeTab}
          tab={tab}
          label={tab}
          handleTabChange={handleTabChange}
          setTab={setActiveTab}
        />
      ))}
    </>
  );
};
