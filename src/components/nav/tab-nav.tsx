import { Tabs } from '../../ts/enums/tabs-enum';
import { TabButton } from '../buttons/tab-button';
import { useCore } from '../../hooks/use-core';
import { useHandleTabChange } from '../../helpers/use-handle-tab-change';

export const TabNav = () => {
  const { activeTab, setActiveTab } = useCore();
  const handleTabChange = useHandleTabChange();
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
