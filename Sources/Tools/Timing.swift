import Foundation

public func getSecondsFromMachTimer(duration: UInt64) -> Double {
	var baseInfo = mach_timebase_info_data_t(numer: 0, denom: 0)

	if mach_timebase_info(&baseInfo) == KERN_SUCCESS {
		return Double(duration * UInt64(baseInfo.numer) / UInt64(baseInfo.denom)) * 0.000000001
	} else {
		fatalError()
	}
}
